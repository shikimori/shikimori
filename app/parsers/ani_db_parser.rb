require 'progressbar'

# TODO: переделать матчинг аниме на NameMatcher по аналогии с FindAnimeImporter
class AniDbParser < SiteParserWithCache
  alias :super_load_cache :load_cache

  ANIME_URL = "http://anidb.net/perl-bin/animedb.pl?show=anime&aid=%d"
  ANIME_SCORE_URL = "http://anidb.net/perl-bin/animedb.pl?show=votes&aid=%d"
  ANIMES_DUMP_URL = "http://anidb.net/api/animetitles.dat.gz"
  RATING_REGEXP = />Rating[\s\S]*?<span class="rating[\s\S]*?>([\d.]+)/
  TMP_RATING_REGEXP = />Rating[\s\S]*?<span class="rating[\s\S]*?>([\d.]+)/
  CONTENT_REGEXP = /<td width=1><\/td><td valign=top><font size=3><b>(.*?) \[<\/font><a href='list.php\?year=\d+'><font size=3 color=#990000>(\d+)<\/font><\/a><font size=3>\]<\/b><\/font>(.*)<font size=2><br><br><b>/
  SCORES_REGEXP = /<div class="bar" title="(\d+) users voted (\d+)/
  #STUDIOS_LIST_URL = "http://anidb.net/perl-bin/animedb.pl?show=creatorlist&orderby.name=1.1&orderby.creatortype=0.2&orderbar=0&noalias=2&page=%d"
  STUDIOS_LIST_URL = "http://anidb.net/perl-bin/animedb.pl?show=creatorlist&page=%d"
  STUDIOS_START_PAGE = 0
  STUDIOS_END_PAGE = 1002
  STUDIO_REGEX = /<tr>\s+<td.*? creator">\s+<a href="(.*?)"[\s\S]*?<td class="type">(.*?)<\/td>/
  STUDIO_URL = "http://anidb.net/perl-bin/animedb.pl?show=creator&creatorid=%d"

  # конструктор
  def initialize
    super
    @required_text = 'AniDB'
    @proxy_log = false
  end

  # сохранение кеша
  def load_cache
    super_load_cache

    if @cache[:animes] == nil
      fetch_and_apply_animes_dump
    end
    if @cache[:studios] == nil
      @cache[:studios] = {}
      fetch_studios_list
      save_cache
    end
    print "cache loaded\n" if Rails.env != 'test'
    @cache
  end

  def clear_studios
    @cache[:studios].each do |k,v|
      @cache[:studios][k] = {}
    end
    save_cache
  end

  # загрузка всех не загруженных аниме
  def fetch_animes(reload=false)
    print "fetching animes...\n"
    animes = reload ? @cache[:animes] : @cache[:animes].select {|k,v| !v.include?(:scores) || (v[:scores].respond_to?(:[]) && (v[:scores].empty? || v[:scores].sum == 0)) }
    print "%i of %i left\n" %
      [
        animes.size,
        @cache[:animes].size
      ]

    begin
      pbar = ProgressBar.new("fetching animes info", animes.size) if (Rails.env == 'development' || Rails.env == 'test')
      #animes.each do |anime_id, anime|
      animes.parallel(:threads => 100, :timeout => 30) do |anime_id, anime|
        fetch_score(anime)
        #ap anime[:scores] if !anime.include?(:scores) || anime[:scores].empty? || anime[:scores].sum == 0
        @mutex.synchronize { pbar.inc } if (Rails.env == 'development' || Rails.env == 'test')
      end
      pbar.finish if (Rails.env == 'development' || Rails.env == 'test')
    rescue Exception => e
      print "%s\n%s\n" % [e.message, e.backtrace.join("\n")]
    end
    print "all animes fetched successfully...\n"
    save_cache
  end

  # получение оценок аниме по его id
  def fetch_score(anime)
    content = Proxy.get(ANIME_URL % anime[:id],
                        timeout: 30,
                        required_text: @required_text,
                        ban_texts: MalFetcher.ban_texts,
                        log: @proxy_log)
    return nil unless content

    #scores = content.gsub(SCORES_REGEXP).map do |v|
      #v.match(SCORES_REGEXP) ? $1.to_i : 0
    #end
    #anime[:scores] = scores.take(10)
    #anime[:scores] = scores.drop(10).take(10) if anime[:scores].sum == 0
    if content.match RATING_REGEXP
      anime[:scores] = $1.to_f
    elsif content.match TMP_RATING_REGEXP
      anime[:scores] = $1.to_f
    end

    anime
  end

  def fetch_studios(reload=false)
    @cache[:studios].parallel do |k,v|
      next unless v == {} || reload
      data = fetch_studio(k)
      if data
        if @cache[:studios].include?(k)
          @cache[:studios][k].merge!(data)
        else
          @cache[:studios][k] = data
        end
        print "fetched studio name: #{data[:name]}, id: #{data[:id]}\n"
      else
        print "can't fetch studio id: #{k}\n"
      end
    end
    save_cache
  end

  def fetch_studio(id)
    content = Proxy.get(STUDIO_URL % id, timeout: 30, required_text: @required_text, ban_texts: MalFetcher.ban_texts, :log => @proxy_log)
    return nil unless content
    data = {:id => id}
    data[:name] = $1 if content.match(/<tr class="[^"]*?mainname[^"]*?">[\s\S]+?<td class="value">(.*?)\s+\(<a/)
    data[:japanese] = $1 if content.match(/<tr class="[^"]*?official[^"]*?"[\s\S]+?<label>(.*?)<\/label>/)
    data[:roles] = $1 if content.match(/<tr class="[^"]*?roles[^"]*?"[\s\S]+?<td class="value">(.*?)<\/td>/)
    data[:logo] = $1 if content.match(/<div class="image">\s+<img[^>]+src="([^"]+)"/) && !$1.include?('nopic.gif')
    data[:description] = $1.strip if content.match(/<!--block-->\s+<div class="[^"]*?g_bubble[^"]*?"[^>]*>([\s\S]*?)<\/div>/)
    if content.match(/<tr class="[^"]*?birthdate[^"]*?"[\s\S]+?<td class="value">(.*?)<\/td>/)
      date = $1.gsub(/\?+\./, '')
      data[:birthdate] = begin
        if date.match(/^\d+$/)
          Date.new(date.to_i)
        elsif date.match(/^(\d+)\.(\d+)$/)
          Date.new($2.to_i, $1.to_i)
        else
          Date.parse(date)
        end
      rescue Exception => e
        nil
      end
    end
    data[:name] ? data : nil
  end

  # загрузка списка студий с сайта
  def fetch_studios_list
    pages = []
    STUDIOS_START_PAGE.upto(STUDIOS_END_PAGE) {|v| pages << v }
    pages.parallel(:threads => 20) do |page|
      content = Proxy.get(STUDIOS_LIST_URL % page, timeout: 30, required_text: @required_text, ban_texts: MalFetcher.ban_texts, log: @proxy_log)
      next unless content
      studios_found = 0
      content.gsub(STUDIO_REGEX).map do |v|
        if v.match(STUDIO_REGEX)
          next if $2 != "Company"
          id = $1.match(/\d+$/)[0].to_i
          @cache[:studios][id] = {} unless @cache[:studios].include?(id)
        end
        studios_found += 1
      end
      print "page: #{page}, studios found: #{studios_found}\n"
      #break if studios_found == 0
    end
  end

  # загрузка дампа названий аниме
  def fetch_and_apply_animes_dump(try=0)
    print "fetching animes dump attempt #{try}\n"
    content = Proxy.get(ANIMES_DUMP_URL, timeout: 120, required_text: @required_text, ban_texts: MalFetcher.ban_texts, log: @proxy_log, no_proxy: true)
    unless content
      return nil if try >= 3
      return fetch_and_apply_animes_dump(try+1)
    end
    File.open('/tmp/animetitles.dat.gz', 'wb') {|h| h.write(content) }
    %x(rm -f /tmp/animetitles.dat)
    %x(e /tmp/animetitles.dat.gz)
    data = File.open(File.exists?('/tmp/animetitles.dat') ? '/tmp/animetitles.dat' : '/tmp/animetitles.dat.gz', 'r') {|h| h.readlines }.map do |v|
      next if v.first == '#'
      id = v.split('|')[0].to_i
      next if id == 0
      [id, v.split('|')[3].strip]
    end.compact
    print "fetched #{data.size} dump entries\n"

    if data && data.size > 0
      @cache[:animes] = {} unless @cache.include?(:animes)
      data.each do |entry|
        if @cache[:animes].include?(entry[0])
          @cache[:animes][entry[0]][:names] << entry[1]
        else
          @cache[:animes][entry[0]] = {:id => entry[0], :names => [entry[1]]}
        end
      end
    end
  end

  # слияние данных аниме из кеша с данными в базе
  def merge_animes_with_database
    print "preparing animes for merge...\n"
    Anime.update_all ani_db_id: 0, ani_db_scores: nil

    animes = Anime.where(:kind.not_in => ['Music', 'Special']).
                  #where(:id => [10187]).
                  #select('id, name, synonyms, english, japanese, status, episodes_aired, episodes').all
                  all
    animes = animes.map {|a| {:names => [fix_name(a.name)] +
                                        (a.english ? a.english.map {|v| fix_name(v) } : []) +
                                        (a.synonyms ? a.synonyms.map {|v| fix_name(v) } : []),
                              :anime => a} }
    print "fetched #{animes.size} animes from database\n"
    #@cache[:animes] = Hash[*@cache[:animes].select {|k,v| [8287].include?(k) }.flatten]
    pbar = ProgressBar.new("preparing cached data", @cache[:animes].size)
    @cache[:animes].each do |k,v|
      v[:d_names] = v[:names].map {|v| HTMLEntities.new.decode(fix_name(v)) }
      #v[:d_names] = v[:names].map {|v| fix_name(v) }
      pbar.inc
    end
    pbar.finish

    # допиливание базы руками, чтобы все корректно смержилось
    @cache[:animes][4932][:d_names] = ['kara no kyoukai 1: fukan fuukei']
    @cache[:animes][8287][:d_names] = ['hen zemi (2011)']
    @cache[:animes][7432][:d_names] = ['Mirai Nikki OVA']
    @cache[:animes][8395][:d_names] = ['Mirai Nikki']

    found = 0
    pbar = ProgressBar.new("merging with AniDb animes", @cache[:animes].size)
    @cache[:animes].each do |w_id, w_anime|
      animes.each do |anime|
        next if anime[:ani_db_id] && anime[:ani_db_id] > 0
        if anime[:names].any? {|v| w_anime[:d_names].include?(v) }
          anime[:anime].update_attributes(:ani_db_id => w_anime[:id], :ani_db_scores => w_anime[:scores])
          found += 1
        end
      end
      pbar.inc
    end
    pbar.finish
    print "%d intersections found\n" % found
  end

  # слияние данных аниме из кеша с данными в базе
  def merge_studios_with_database
    studios = Studio.all
    #studios = [Studio.find(41)]
    studios.each {|v| v.ani_db_id = nil }

    # допиливание базы руками, чтобы все корректно смержилось
    @cache[:studios][718][:logo] = 'http://images4.wikia.nocookie.net/__cb20100906105718/gundam/images/4/40/Gainax_logo.gif'
    @cache[:studios][720][:logo] = 'http://img217.imageshack.us/img217/3595/jcstaff.png'
    @cache[:studios][720][:name] = 'J.C. Staff'
    @cache[:studios][721][:logo] = 'http://img340.imageshack.us/img340/8893/selection006m.png'
    @cache[:studios][723][:logo] = 'http://tezukaosamu.net/images/top_logo.gif'
    @cache[:studios][723][:name] = studios.select {|v| v.id == 200 }.first.name
    @cache[:studios][724][:logo] = 'http://img858.imageshack.us/img858/6155/selection004.png'
    @cache[:studios][726][:logo] = 'http://img808.imageshack.us/img808/7109/sunrise.png'
    @cache[:studios][729][:logo] = 'http://img821.imageshack.us/img821/5476/selection003m.png'
    @cache[:studios][730][:logo] = 'http://img863.imageshack.us/img863/1817/deen.png'
    @cache[:studios][731][:name] = studios.select {|v| v.id == 11 }.first.name
    @cache[:studios][731][:logo] = 'http://img12.imageshack.us/img12/6756/madhousef.png'
    @cache[:studios][732][:logo] = 'http://img718.imageshack.us/img718/623/aic.png'
    @cache[:studios][735][:logo] = 'http://img853.imageshack.us/img853/4686/studiogonzo.png'
    @cache[:studios][736][:logo] = 'http://www.kyotoanimation.co.jp/img/logo.png'
    @cache[:studios][738][:name] = studios.select {|v| v.id == 13 }.first.name
    @cache[:studios][762][:logo] = 'http://img269.imageshack.us/img269/3345/aniplex.jpg'
    @cache[:studios][769][:name] = 'A.C.G.T.'
    @cache[:studios][769][:name] = 'A.C.G.T.'
    @cache[:studios][771][:logo] = 'http://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Arms_Corporation.png/200px-Arms_Corporation.png'
    @cache[:studios][774][:logo] = 'http://img833.imageshack.us/img833/4267/grouptac.png'
    @cache[:studios][788][:logo] = 'http://img836.imageshack.us/img836/6188/selection002.png'
    @cache[:studios][811][:name] = 'APPP'
    @cache[:studios][830][:logo] = 'http://media.strategywiki.org/images/thumb/5/58/TatsunokoProduction_logo.jpg/250px-TatsunokoProduction_logo.jpg'
    @cache[:studios][830][:name] = studios.select {|v| v.id == 103 }.first.name
    @cache[:studios][833][:name] = studios.select {|v| v.id == 68 }.first.name
    @cache[:studios][839][:logo] = 'http://img268.imageshack.us/img268/7268/cometf.png'
    @cache[:studios][905][:logo] = 'http://img840.imageshack.us/img840/9493/animax.png'
    @cache[:studios][917][:logo] = 'http://www.tms-e.co.jp/shared/img/logo.gif'
    @cache[:studios][982][:logo] = 'http://img818.imageshack.us/img818/7564/brainsbase.png'
    @cache[:studios][986][:logo] = 'http://img810.imageshack.us/img810/4407/manglobe.png'
    @cache[:studios][1117][:logo] = 'http://img828.imageshack.us/img828/7218/ufotable.png'
    @cache[:studios][1284][:logo] = 'http://www.shin-ei-animation.jp/images/top/logo.gif'
    @cache[:studios][1303][:name] = 'A-1 Pictures Inc.'
    @cache[:studios][1303][:logo] = 'http://img856.imageshack.us/img856/1774/90467519.png'
    @cache[:studios][1341][:name] = studios.select {|v| v.id == 411 }.first.name
    @cache[:studios][1385][:logo] = 'http://img848.imageshack.us/img848/6643/paworks.png'
    @cache[:studios][1834][:logo] = 'http://shakko.com/images/stories/toei animation.jpg'
    @cache[:studios][5586][:name] = studios.select {|v| v.id == 390 }.first.name
    @cache[:studios][10023][:name] = studios.select {|v| v.id == 379 }.first.name
    @cache[:studios][10319][:name] = studios.select {|v| v.id == 450 }.first.name
    @cache[:studios][19343][:name] = studios.select {|v| v.id == 258 }.first.name
    @cache[:studios][19386][:name] = studios.select {|v| v.id == 409 }.first.name
    @cache[:studios][19459][:name] = studios.select {|v| v.id == 189 }.first.name

    s = studios.select {|v| v.id == 95 }.first
    s.image = open('http://img687.imageshack.us/img687/6709/dogakobologo.png')
    raise "проверить сохраняется ли корректно картинка"
    s.save

    found = 0
    pbar = ProgressBar.new("merging with AniDb studios", @cache[:studios].size)
    @cache[:studios].each do |w_id, w_studio|
      studios.each do |studio|
        if studio.name.downcase == w_studio[:name].downcase
          studio.japanese = w_studio[:japanese] if w_studio[:japanese]
          studio.ani_db_id = w_id
          studio.ani_db_name = w_studio[:name]
          studio.ani_db_description = w_studio[:description]
          if w_studio[:logo]
            studio.image = open(w_studio[:logo])
            raise "проверить сохраняется ли корректно картинка"
          end
          studio.save
          found += 1
        end
      end
      pbar.inc
    end
    pbar.finish
    print "%d intersections found\n" % found

    found = 0
    pbar = ProgressBar.new("looking for partially matched AniDb studios", studios.select {|v| !v.ani_db_id }.size)
    studios.select {|v| !v.ani_db_id }.each do |studio|
      @cache[:studios].each do |w_id, w_studio|
        if studio.filtered_name.downcase == Studio.filtered_name(w_studio[:name]).downcase
          ap [w_id, studio.id]
        end
      end
      pbar.inc
    end
    pbar.finish
    print "%d intersections found\n" % found

  end
end
