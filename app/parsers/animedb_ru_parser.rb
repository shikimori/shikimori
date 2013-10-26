class AnimedbRuParser < WorldArtParser
  AnimeUrl = "http://animedb.ru/?id=%s"
  AnimeImagesUrl = "http://animedb.ru/?id=%s&screen"

  # конструктор
  def initialize
    super
    @required_text = ['Animedb.ru', '</html>']
    @proxy_log = false
    @no_proxy = true
  end

  # максимальный id аниме в базе
  def fetch_max_id
    content = Proxy.get('http://animedb.ru/encyclopedia.php?request=&year=0000&tp=10&genre=00&order=1&sort=2', no_proxy: true, log: @proxy_log)
    if content =~ /Показано с \d+ по (\d+) из (\d+)/
      max_id = $2.to_i
    else
      raise 'design of max_id page had changed'
    end
    max_id
  end

  # условие загрузки ание
  def should_load?(anime_id)
    !@cache[:animes].include?(anime_id) || (@cache[:animes][anime_id][:screenshots].empty? && @cache[:animes][anime_id][:year] > 2004)
  end

  # условие загрузки ание
  def fetch_ids_with_screenshots
    get('http://animedb.ru/').gsub(/<a.*?href="(.*?)".*Кадры/)
                             .map {|v| $1.match(/\d+/)[0].to_i }
  end

  # перезагрузка указанных элементов
  def update_animes(ids)
    ids.each do |id|
      @cache[:animes][id] = fetch_anime(id)
    end
    save_cache
  end

  # загрузка аниме
  def fetch_anime(id)
    content = get(AnimeUrl % id)
    return nil unless content

    anime = { :id => id, :url => AnimeUrl % id }

    doc = Nokogiri::HTML(content)
    anime[:name] = doc.css('.content h1').first.inner_text.sub(/\(.*\)/, '').strip
    anime[:russian] = doc.css('.content h2').first.inner_text.sub(/ \(.*\)$/, '').strip

    h3 = doc.css('h3').first
    titles = doc.css('h3.titles').first
    anime[:names] = (h3 ? [h3.text] : []) +
                      (titles ? titles.to_html.split(/<br>|\n/).map(&:strip).map {|v| v.gsub(/<.*?>/, '').strip }.select {|v| !v.blank? } : [])
    anime[:year] = doc.css('.year').first.inner_text.sub(/\(|\)/, '').to_i

    anime[:kind] = if content =~ /Тип:<\/b> (.*?),/
      case Unicode.downcase($1)
        when /фильм/ then 'Movie'
        when /тв-сериал|tv/ then 'TV'
        when /\ova/ then 'OVA'
        when /\ona/ then 'ONA'
        when /спэшл|special|cпэшл/ then 'Special'
        when /музыкальный клип/ then 'Music'
        when /короткометражка|рекламный ролик/ then nil
        else raise "unknown kind for anine #{id}"
      end
    else
      raise "unknown kind for anine #{id}"
    end

    anime[:screenshots] = if content.include? 'Все кадры ('
      s_content = get(AnimeImagesUrl % id)
      return nil unless s_content
      s_doc = Nokogiri::HTML(s_content)
      s_doc.css('.content a.fancybox').map {|v| "http://animedb.ru/%s" % v.attr('href').sub('_small', '') } +
        s_doc.css('a[rel=example_group]').map {|v| "http://animedb.ru/%s" % v.attr('href').sub('_small', '') }.select {|v| v.include? 'images/screen_' }
    else
      []
    end

    #ap "#{anime[:name]} #{anime[:year]} #{anime[:kind]}"
    anime
  #rescue Exception => e
    #raise e if e.class == Interrupt
    #print "#{id} #{e.message}\n#{e.backtrace.join("\n")}...\n"
    #nil
  end

  # импорт в базу русских названий
  def merge_russian(ids=nil)
    print "preparing animes for russian merge...\n" if Rails.env != 'test'
    animes = Anime.where { kind.not_in(['Music', 'Special']) }.
                   #where(:id => 10620).
                   all

    animes = animes.map do |a|
      {
        :names => [fix_name(a.name)] +
                  (a.english ? a.english.map {|v| fix_name(v) } : []) +
                  (a.synonyms ? a.synonyms.map {|v| fix_name(v) } : []) +
                  (a.japanese ? a.japanese.map {|v| fix_name(v) } : []),
        :anime => a
      }
    end
    print "fetched #{animes.size} animes from database\n" if Rails.env != 'test'
    print "#{@cache[:animes].size} animes in AnimedbRu's cache\n" if Rails.env != 'test'

    apply_fixes

    found = 0
    pbar = ProgressBar.new("merging with AnimedbRu animes", @cache[:animes].size) if Rails.env != 'test'
    @cache[:animes].select {|k,v| v && v.include?(:names) }.each do |w_id, w_anime|
      next if ids && !ids.include?(w_id)
      d_names = w_anime[:names].map {|name| fix_name(name) } + [fix_name(w_anime[:name])]

      animes.each do |anime|
        if (anime[:names] & d_names).any? || w_anime[:mal_id] == anime[:anime].id

          if anime[:anime].russian.blank?
            anime[:anime].russian = w_anime[:russian]
            apply_mal_fixes(anime[:anime])
            anime[:anime].save
          end
          w_anime[:mal_id] = anime[:anime].id if anime[:anime].kind == w_anime[:kind]

          found += 1
          break if w_anime[:mal_id] == anime[:anime].id
        end
      end
      pbar.inc if Rails.env != 'test'
    end
    pbar.finish if Rails.env != 'test'

    print "%d intersections found\n" % found if Rails.env != 'test'
    save_cache
  end

  # импорт в базу скриншотов
  def merge_screenshots
    print "preparing animes for screenshots merge...\n" if Rails.env != 'test'

    (@cache[:animes][6508] ||= {})[:screenshots] = [] # для этого аниме ошибка у них
    (@cache[:animes][6770] ||= {})[:screenshots] = [] # этого ONA нет на шикимори Mahou Tsukai Nara Miso o Kue!
    (@cache[:animes][6896] ||= {})[:screenshots] = [] # этого нет на шикимори Mahou Tsukai Nara Miso wo Kue!
    (@cache[:animes][6872] ||= {})[:screenshots] = [] # этого нет на шикимори Beast Saga
    data = @cache[:animes].select {|k,v| v[:screenshots].any? && v[:mal_id] }.map {|k,v| v }
    print "fetched #{data.size} animes with screenshots from AnimedbRu\n" if Rails.env != 'test'
    print "found #{Screenshot.count} screenshots in database\n" if Rails.env != 'test'

    # аниме с пользовательскими правками скриншотов не берём
    changes = UserChange.where(column: 'screenshots', status: [UserChangeStatus::Accepted, UserChangeStatus::Taken]).select('distinct(item_id)').map(&:item_id)
    animes = Anime.where(:id => data.map {|v| v[:mal_id] })
                  .includes(:screenshots)
                  .all
                  #.where(:id.not_in => changes.empty? ? [0] : changes)

    screenshots = Set.new animes.map(&:screenshots).flatten.map {|v| "#{v.anime_id}:#{v.url}" }
    unmatched_animes = @cache[:animes].select {|k,v| v[:screenshots].any? && v[:mal_id].nil? && v[:year] > 1980 }

    screenshots_to_import = data.sum do |anime|
      anime[:screenshots].sum do |url|
        screenshots.include?("#{anime[:mal_id]}:#{url}") ? 0 : 1
      end
    end

    # дебаг логи
    if Rails.env != 'test'
      print "fetched #{animes.count} animes from database\n" 
      print "not imported screenshots: #{screenshots_to_import}\n"

      if unmatched_animes.size > 0
        print "#{unmatched_animes.size} not matched animes with screenshots:\n"
        unmatched_animes.each do |id,anime|
          ap "#{anime[:id]} #{anime[:name]}"
        end
      end
    end
    raise 'Found unmatched animes. Execute `AnimedbRuParser.new.merge_screenshots` for details' if unmatched_animes.any?

    pbar = ProgressBar.new("merging with AnimedbRu animes", screenshots_to_import)
    data.reverse.each do |anime|
      ActiveRecord::Base.transaction do
        ids = []
        anime[:screenshots].each do |url|
          next if screenshots.include?("#{anime[:mal_id]}:#{url}")

          begin
            io = open(url)
            def io.original_filename; base_uri.path.split('/').last; end

            shot = Screenshot.create!(:image => io, :anime_id => anime[:mal_id], :url => url, position: 9999)
            ids << shot.id
          rescue Exception => e
            exit if e.class == Interrupt
            print "anime: #{anime[:id]}\nscreenshot: #{url}\nerror: #{e.message}\n#{e.backtrace.join("\n")}\n"
          end
          pbar.inc if Rails.env != 'test'
        end # screenshots
        next if ids.empty?
        Screenshot.where(:id => ids)
                  .update_all(:status => Screenshot::Uploaded)
        UserChange.create!({
          action: UserChange::ScreenshotsUpload,
          column: 'screenshots',
          model: Anime.name,
          item_id: anime[:mal_id],
          user_id: BotsService.get_poster.id,
          value: ids.join(',')
        })
      end # transaction
    end # animes
    pbar.finish if Rails.env != 'test'
  end

  # ручная подгонка названий
  def apply_fixes
    link(3908, 121) # Fullmetal Alchemist
    link(5472, 5114) # Fullmetal Alchemist: Brotherhood
    link(3430, 71) # Full Metal Panic
    link(2619, 818) # Sakura Tsuushin
    link(3157, 1124) # Seikai no Dansho - Tanjyou
    link(3390, 1406) # Gibo
    link(3486, 2944) # Seisai
    link(3591, 337) # Psychic Academy Ourabanshou
    link(4101, 546) # Wind: A Breath of Heart
    link(4633, 1067) # Kishin Houkou Demonbane
    link(4762, 1591) # Kujibiki Unbalance
    link(4813, 1862) # Strike Witches OVA
    link(6177, 9751) # Strike Witches Movie
    link(4975, 2602) # Kenkoo Zenrakei Suieibu Umishou
    link(5148, 3342) # Mnemosyne - Mnemosyne no Musume-tachi
    link(5228, 4136) # Penguin Musume Heart
    link(4545, 837) # Kyou no Go no Ni OVA1
    link(5332, 4903) # Kyou no Go no Ni
    link(5618, 6379) # Kyou no Go no Ni OVA2
    link(5419, 4970) # Afro Samurai: Resurrection
    link(6243, 6864) # xxxHOLiC Rou Adayume
    link(6257, 10794) # IS: Infinite Stratos Encore - Koi ni Kogareru Rokujuusou
    link(6422, 11179) # Papa no Iukoto o Kikinasai!
    link(6472, 12321) # Thermae Romae
    link(6420, 11617) # Highschool DxD
    link(6428, 11285) # Black Rock Shooter TV
    link(5857, 7059) # Black Rock Shooter OVA
    link(1043, 8972) # Mahou no Princess Minky Momo vs. Mahou no Tenshi Creamy Mami
    link(1046, 2250) # Onboro Film
    link(6510, 11741) # Fate / Zero 2
    link(6443, 11785) # Haiyore! Nyaruko-san
    link(5264, 4262) # Koihime Musou
    link(5617, 6112) # Shin Koihime Musou
    link(5758, 8057) # Shin Koihime Musou: Otome Tairan
    link(6444, 11813) # Shijou Saikyou no Deshi Kenichi
    link(6533, 12875) # Ginga e Kickoff!!
    link(6546, 12979) # Rock Lee no Seishun Full-Power Ninden
    link(6566, 13139) # Gakkatsu
    link(6579, 13019) # Aneki no Kounai Kaikinbi
    link(6596, 12677) # Ozuma
    link(6554, 12997) # Please R*pe Me!"
    link(6468, 13057) # Pisu Hame!
    link(6760, 14693) # Yurumates 3D Plus
    link(6578, 11021) # Total Eclipse
    link(6469, 12317) # Upotte!!
    link(6502, 12293) # Campione!
    link(6443, 11785) # Haiyore! Nyaruko-san
    link(6773, 14657) # Netorare Zuma
    link(6792, 14719) # JoJo no Kimyou na Bouken
    link(6858, 15417) # Gintama 2012
    link(6882, 15649) # Petit idolmaster
    link(6936, 15689) # Nekomonogatari
    link(6767, 15051) # Love Live!
    link(6795, 14827) # D.C.III: Da Capo III
    link(6770, 14479) # Mahou Tsukai Nara Miso o Kue!"
  end
end
