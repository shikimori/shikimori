# TODO: переделать матчинг аниме на NameMatcher по аналогии с FindAnimeImporter
#class WorldArtParser < SiteParserWithCache
  #AnimeUrl = "http://www.world-art.ru/animation/animation.php?id=%d"
  ##AnimeScreenshotsUrl = "http://www.world-art.ru/animation/animation_photos.php?id=%d&type=screenshots"
  #AnimeScoreUrl = "http://www.world-art.ru/animation/votes_history.php?id=%d"
  #ContentRegexp = /<td width=1><\/td>[\S]*<td valign=top><font size=3><b>(.*?) \[<\/font><a href='(?:http:\/\/www.world-art.ru\/animation\/)?list.php\?public_year=\d+'><font size=3 color=#990000>(\d+)<\/font><\/a><font size=3>\]<\/b><\/font>(.*)<font size=2><br><br><b>/
  #ScoreRegexp = /<b>Средний балл<\/b>[\s\S]*?:&nbsp;([\d.]+)/
  #ScoresRegexp = /<table><tr><td width=30 align=right>(\d+)<\/td><td width=100 align=left>&#151;&#151;&#151;&#151; (\d+)/

  ## конструктор
  #def initialize
    #super
    #@required_text = ['World Art']
    ##@proxy_log = true
  #end

  ## загрузка кеша
  #def load_cache
    #super

    #unless @cache[:animes]
      #@cache[:animes] = {}
      #save_cache
    #end
    #unless @cache[:scores]
      #@cache[:scores] = {}
      #save_cache
    #end
    #unless @cache[:max_id]
      #@cache[:max_id] = fetch_max_id
      #save_cache
    #end
    #print "cache loaded\n" if Rails.env != 'test'
    #@cache
  #end

  ## условие загрузки ание
  #def should_load?(anime_id)
    #!@cache[:animes].include?(anime_id)
  #end

  ## загрузка всех не загруженных аниме
  #def fetch_animes(reload=false)
    #print "fetching animes...\n"
    #data = []
    #1.upto(@cache[:max_id]) do |anime_id|
      #next if !should_load?(anime_id) && !reload
      #data << anime_id
    #end
    #print "%i of %i left\n" %
      #[
        #data.size,
        #@cache[:max_id]
      #]

    #data.each do |anime_id|
      #anime = fetch_anime(anime_id)
      #@cache[:animes][anime_id] = anime if anime
    #end

    #save_cache
  #end

  ## получение аниме по его id
  #def fetch_anime(id)
    #content = get(AnimeUrl % id)
    #return nil unless content
    #binding.pry
    #content = content.force_encoding('windows-1251').encode('utf-8') unless content =~ ContentRegexp

    #anime = {
      #id: id,
      #url: AnimeUrl % id,
    #}

    #content =~ ContentRegexp
    #anime[:rus] = $1

    ## доп проверка на случай кривой кодировки
    #begin
      #$1.each_char {|v| v.ord }
      #$3.each_char {|v| v.ord }
    #rescue
      #content = content.force_encoding('windows-1251').encode('utf-8')
      #content =~ ContentRegexp
      #anime[:rus] = $1
    #end
    #anime[:year] = $2.to_i
    #anime[:names] = $3.gsub(/^<br>|<br>$/, '').split("<br>").map {|v| HTMLEntities.new.decode(v) }

    #if content =~ ScoreRegexp
      #anime[:score] = $1.to_f
      #fetch_score(anime)
    #end

    #anime
  #rescue Exception => e
    #raise e if e.class == Interrupt
    #print "#{id} #{e.message}...\n"

    #nil
  #end

  ## получение оценок аниме по его id
  #def fetch_score(anime)
    #content = get(AnimeScoreUrl % anime[:id])
    #return nil unless content

    #anime[:scores] = content.gsub(ScoresRegexp).map {|v|
      #v.match(ScoresRegexp) ? $2.to_i : 0
    #}.reverse
    #anime
  #end

  ## получение максимального id аниме на ворлдарте
  #def fetch_max_id
    #content = Proxy.get('http://www.world-art.ru/animation/list.php?public_type=&lit=&year=&genre=&sort=5', no_proxy: true, log: @proxy_log)
    #content = content.force_encoding('windows-1251').encode('utf-8') if content.encoding.name != 'UTF-8'
    #max_id = content.gsub(/animation.php\?id=\d+/).map {|v| v.sub(/.*?(?=\d)/, '').to_i }.max
    ##print "max_id: #{max_id}\n"
    #max_id
  #end

  ## слияние данных из кеша с данными в базе
  #def merge_with_database
    #print "preparing animes for merge...\n"
    ##ActiveRecord::Base.connection.execute("update animes set world_art_id=0, world_art_scores=null, russian=null")
    #animes = Anime.where { kind.not_in(['Music', 'Special']) }.
                   ##where(:id => [355]).
                   ##select('id, name, synonyms, english, japanese, status, episodes_aired, episodes').all
                   #all
    #animes = animes.map do |a|
      #{
        #:names => [fix_name(a.name)] +
                  #(a.english ? a.english.map {|v| fix_name(v) } : []) +
                  #(a.synonyms ? a.synonyms.map {|v| fix_name(v) } : []) +
                  #(a.japanese ? a.japanese.map {|v| fix_name(v) } : []),
        #:anime => a
      #}
    #end
    #print "fetched #{animes.size} animes from database\n"

    ##@cache[:animes] = Hash[*@cache[:animes].select do |k,v|
      ##[
        ##2708, 6476, 3024, 6303, 6740, 6741, 6950, 6969, 7118, 7315, 7826, 6410, 4981, 4660, 6773, 7637, 6078, 5820, 5820, 5793, 7288, 402, 7180, 7448, 401, 7761, 4737, 8001, 6078, 723, 2581, 6460, 1002
      ##].include?(k)
    ##end.flatten]

    #cache = @cache[:animes].select {|k,v| v && v.include?(:names) }
    #print "#{cache.size} animes in Worldart's cache\n"

    #cache.each do |k,v|
      #v[:d_names] = v[:names].map {|name| HTMLEntities.new.decode(fix_name(name)) } + [HTMLEntities.new.decode(fix_name(v[:rus]))]
    #end

    #apply_fixes
    #link(6476, 8246) # Naruto: Shippuuden Movie 4 - The Lost Tower
    #link(2708, 1764) # Slam Dunk Movie 1
    #link(3024, 507) # Graviation

    #found = 0
    #@cache[:animes].select {|k,v| v && v.include?(:names) }.each do |w_id, w_anime|
      #animes.each do |anime|
        #next unless w_anime[:d_names]
        ##next if anime[:world_art_id] && anime[:world_art_id] != 0
        ##ap [w_anime[:d_names], anime[:names]]
        ##ap w_anime[:d_names] & anime[:names]
        #if (anime[:names].any? {|v| w_anime[:d_names].include?(v) } &&
            #!w_anime.include?(:mal_id) &&
            #!(w_anime[:rus].include?('OVA') && anime[:anime].kind != 'OVA') # если есть в русском названии OVA, то из аниме только OVA выбираем
           #) ||
           #(w_anime.include?(:mal_id) && w_anime[:mal_id] == anime[:anime].id)
          ##ap [w_anime, anime]
          #if w_anime[:rus].match(/[а-яА-Я]/)
            #anime[:anime].world_art_id = w_anime[:id]
            #anime[:anime].russian = w_anime[:rus] if anime[:anime].russian.blank?
            #anime[:anime].world_art_scores = w_anime[:scores]

            #apply_mal_fixes(anime[:anime])

            #anime[:anime].save
          #else
            #anime[:anime].update_attributes(:world_art_id => w_anime[:id], :world_art_scores => w_anime[:scores]) # , :world_art_synonyms => w_anime[:names]
          #end
          #found += 1
          #break
        #end
      #end
    #end
    #print "%d intersections found\n" % found
  #end

  ## связать аниме ворлдарта с аниме в базе
  #def link(world_art_id, mal_id)
    #@cache[:animes][world_art_id][:mal_id] = mal_id if @cache[:animes].include? world_art_id
  #end

  ## правки названий. было сделано до того, как link функцию добавил
  #def apply_fixes
    ## допиливание базы руками, чтобы все корректно смержилось
    #if @cache[:animes].include? 6303
      #@cache[:animes][6303][:d_names] << 'kara no kyoukai 1: fukan fuukei'
      #@cache[:animes][6740][:d_names] << 'kara no kyoukai 2: satsujin kousatsu (part 1)'
      #@cache[:animes][6741][:d_names] << 'kara no kyoukai 3: tsuukaku zanryuu'
      #@cache[:animes][6950][:d_names] << 'kara no kyoukai 4: garan no dou'
      #@cache[:animes][6969][:d_names] << 'kara no kyoukai 5: mujun rasen'
      #@cache[:animes][7118][:d_names] << 'kara no kyoukai 6: boukyaku rokuon'
      #@cache[:animes][7315][:d_names] << 'kara no kyoukai 7: satsujin kousatsu (part 2)'
      #@cache[:animes][7826][:d_names] = ['kurenai ova']
      #@cache[:animes][6410][:d_names] = ['clannad']
      #@cache[:animes][405][:rus] = 'Вторжение Кальмарки 2'
      #@cache[:animes][6460][:rus] = 'Пламенный взор Шаны II'
      #@cache[:animes][1002][:rus] = 'Пламенный взор Шаны III'
      #@cache[:animes][6078][:rus] = 'Пламенный взор Шаны OVA-1'
      #@cache[:animes][7637][:rus] = 'Пламенный взор Шаны OVA-2'
      #@cache[:animes][5820][:rus] = 'Пламенный взор Шаны (фильм)'
      #@cache[:animes][5820][:d_names] = ['shakugan no shana movie']
      #@cache[:animes][5793][:d_names] = ['suzumiya haruhi no yuuutsu']
      #@cache[:animes][7288][:d_names] = ['the melancholy of haruhi suzumiya (2009)']
      #@cache[:animes][402][:d_names] = ['yondemasu yo azazelsan (tv)']
      #@cache[:animes][7180][:d_names] = ['asura cryin\'']
      #@cache[:animes][7448][:d_names] = ['asura cryin\' 2']
      #@cache[:animes][401][:d_names] = ['hen zemi (2011)']
      #@cache[:animes][7761][:d_names] = [fix_name('yondemasu yo, azazel-san ova')]
      #@cache[:animes][4737][:d_names] = ['school days ona']
      #@cache[:animes][8001][:d_names] = ['berserk 2']
      #@cache[:animes][6078][:rus] = '636'
      #@cache[:animes][723][:rus] = 'Легенда о героях Галактики'
      #@cache[:animes][2581][:rus] = 'Охотник х Охотник: Зеленый остров'
    #end
  #end

  ## список параметров элементов, заданных руками
  #def mal_fixes
    #unless @mal_fixes
      #all_mal_fixes = YAML::load(File.open("#{::Rails.root.to_s}/config/mal_fixes.yml"))
      #@mal_fixes = all_mal_fixes[:anime]
    #end
    #@mal_fixes
  #end

  #def apply_mal_fixes(entry)
    #mal_fixes[entry.id].each do |k2,v2|
      #entry[k2] = v2
    #end if mal_fixes.include?(entry.id)
  #end
#end
