require 'fileutils'

class SubtitlesTasks
  #include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def ongoing
    print "getting subtitles for ongoings...\n"
    animes = Anime.ongoing
    get_fansubs(animes, :single)
  end
  #add_transaction_tracer :ongoing, :category => :task

  def latest
    print "getting parallel subtitles for latests...\n"
    #animes = Anime.latest.select {|v| !v.anons? }
    animes = Anime.where(AniMangaStatus.query_for('latest')).all
    get_fansubs(animes, :single)
  end
  #add_transaction_tracer :latest, :category => :task

  def regular
    print "getting subtitles for animes..\n"
    animes = Anime.order(:id).all.select {|v| !v.anons? && v.subtitles.empty? && !v.ongoing? }
    get_fansubs(animes, :single)
  end
  #add_transaction_tracer :regular, :category => :task

private
  def get_fansubs(animes, type)
    count = animes.count
    i = 0

    animes.each do |anime|
      cache = FansubsParser.new.import(anime)
      i += 1
      print "%d\t%d\t%d\t%s\n" % [cache.size, count-i, anime.id, anime.name] if cache
      print "failed for %d\t%d\t%s\n" % [count-i, anime.id, anime.name] unless cache
      sleep(3)
    end
  end
end


class TorrentsTasks
  #include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def get_torrents(animes, mode=:parallel)
    #animes = animes.select {|v| v.id == 9367 }
    mutex = Mutex.new
    count = animes.count
    i = 0
    if mode == :parallel
      animes.parallel(:pool_size => 30) do |anime|
        cache = anime.fill_torrents_cache
        mutex.synchronize {
          i += 1
          print "%d\t%d\t%d\t%s\n" % [cache.size, count-i, anime.id, anime.name] if cache
          print "failed for %d\t%d\t%s\n" % [count-i, anime.id, anime.name] unless cache
        }
      end
    elsif mode == :single
      animes.each do |anime|
      cache = anime.fill_torrents_cache
      i += 1
      print "%d\t%d\t%d\t%s\n" % [cache.size, count-i, anime.id, anime.name] if cache
      print "failed for %d\t%d\t%s\n" % [count-i, anime.id, anime.name] unless cache
      end
    end
  end

  def ongoing
    print "getting torrents for ongoings...\n"
    get_torrents(Anime.ongoing.select {|v| v.aired_on && v.aired_on > DateTime.now - 6.month })
  end
  #add_transaction_tracer :ongoing, :category => :task

  def slatest
    print "getting torrents for latests...\n"
    get_torrents(Anime.latest.select {|v| !v.anons? }, :single)
  end

  def latest
    print "getting torrents for latests...\n"
    get_torrents(Anime.latest.select {|v| !v.anons? })
  end
  #add_transaction_tracer :latest, :category => :task

  def regular
    print "getting torrents for animes...\n"
    get_torrents(Anime.order(:id).all.select {|v| !v.anons? && v.torrents.empty? && !v.ongoing? })
  end
  #add_transaction_tracer :regular, :category => :task

  def all
    print "getting torrents for all...\n"
    get_torrents(Anime.all)
  end
  #add_transaction_tracer :regular, :category => :task
end


class ImagesTasks
  #include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def check_empty_anime_images(cache)
    print "checking animes images...\n"
    items = Anime.all
    items.select {|v| v.image.path && !File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      if cache[:animes].include?(v.id) && cache[:animes][v.id][:img] && !cache[:animes][v.id][:img].empty?
        v[:img] = cache[:animes][v.id][:img]
        v.grab_mal_image(true)
      end
    end
    items.select {|v| v.image.path && !File.exists?(v.image.path(:preview))}.each do |v|
      v.image.reprocess!
    end
  end

  def check_empty_characters_images(cache)
    print "checking characters images...\n"
    items = Character.all
    items.select {|v| v.image.path && !File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      v[:img] = cache[:characters][v.id][:img]
      v.grab_mal_image(true)
    end
    items.select {|v| v.image.path && !File.exists?(v.image.path(:preview))}.each do |v|
      v.image.reprocess!
    end
  end

  def check_empty_people_images(cache)
    print "checking people images...\n"
    items = Person.all
    items.select {|v| v.image.path && !File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      v[:img] = cache[:people][v.id][:img]
      next if v[:img].include?("na.gif")
      v.grab_mal_image(true)
    end
    items.select {|v| v.image.path && !File.exists?(v.image.path(:preview))}.each do |v|
      v.image.reprocess!
    end
  end

  def check_empty_images_images(cache)
    print "checking animes related images...\n"
    items = AnimeImage.all
    items.select {|v| v.image.path && !File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      v[:img] = v.mal
      next if v[:img].include?("na.gif")
      v.grab_mal_image(true)
    end
    items.select {|v| v.image.path && !File.exists?(v.image.path(:preview))}.each do |v|
      v.image.reprocess!
    end
  end

  def reload_characters
    cache = MalParser.new.cache
    print "reloading characters images...\n"
    print "total blocks num - %d\n" % [Character.count / 200]

    block_num = 0
    Character.select(:id).all.map {|v| v.id }.select {|v| v.id }.each_slice(200) do |block|
      block_num += 1 and next if Rails.cache.exist?('images_reload_characters') && Rails.cache.read('images_reload_characters') >= block_num
      print "fetching block %d...\n" % [block_num]

      items = Character.where('id in (?)', block).all.select {|v| v.image.path }
      items.parallel(:threads => 40, :saver => false) do |v|
        v[:img] = cache[:characters][v.id][:img]
        v.grab_mal_image(true)
      end
      items.select {|v| v.image.path && !File.exists?(v.image.path(:preview))}.each do |v|
        v.image.reprocess!
      end

      Rails.cache.write('images_reload_characters', block_num)
      block_num += 1
    end
    Rails.cache.delete('images_reload_characters')
  end

  #add_transaction_tracer :reload_latest, :category => :task

  def apply_fixes
    anime_path = "/var/www/anime/original/"
    anime_fixed_path = "/var/www/anime_fixed/original/"
    print "applying user fixed images...\n"
    Dir.entries(anime_fixed_path).each do |entry|
      next if ['.', '..'].include?(entry)
      FileUtils.cp(anime_fixed_path + entry, anime_path + entry)
      anime_id = entry.match(/\d+/)[0].to_i
      anime = Anime.find_by_id(anime_id)
      if anime
        anime.image.reprocess!
        print "applied image for %s\n" % anime.name
      else
        print "anime %d not found\n" % anime_id
      end
    end
  end
  #add_transaction_tracer :apply_fixes, :category => :task

  def check_empty
    cache = MalParser.new.cache
    check_empty_anime_images(cache)
    check_empty_characters_images(cache)
    check_empty_people_images(cache)
    check_empty_images_images(cache)
  end
  #add_transaction_tracer :check_empty, :category => :task

  def check_broken
    cache = MalParser.new.cache

    print "checking animes images...\n"
    Anime.all.select {|v| v.image.path &&
                         File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      data = File.open(v.image.path, "r") {|h| h.read }
      next unless data.starts_with?('Array') || data.starts_with?('<') || data == '\n' || data == "\n" || (data[0..500].include?('<html') && data[0..1000].include?('<head>'))
      File.delete(v.image.path)
      v[:img] = cache[:animes][v.id][:img]
      v.grab_mal_image(true)
    end

    print "checking characters images...\n"
    Character.all.select {|v| v.image.path &&
                              File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      data = File.open(v.image.path, "r") {|h| h.read }
      next unless data.starts_with?('Array') || data.starts_with?('<') || data == '\n' || data == "\n" || (data[0..500].include?('<html') && data[0..1000].include?('<head>'))
      File.delete(v.image.path)
      v[:img] = cache[:characters][v.id][:img]
      v.grab_mal_image(true)
    end

    print "checking people images...\n"
    Person.all.select {|v| v.image.path &&
                           File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      data = File.open(v.image.path, "r") {|h| h.read }
      next unless data.starts_with?('Array') || data.starts_with?('<') || data == '\n' || data == "\n" || (data[0..500].include?('<html') && data[0..1000].include?('<head>'))
      File.delete(v.image.path)
      v[:img] = cache[:people][v.id][:img]
      v.grab_mal_image(true)
    end

    print "checking animes related images...\n"
    AnimeImage.all.select {|v| v.image.path &&
                          File.exists?(v.image.path)}.parallel(:threads => 40, :saver => false) do |v|
      data = File.open(v.image.path, "r") {|h| h.read }
      next unless data.starts_with?('Array') || data.starts_with?('<') || data == '\n' || data == "\n" || (data[0..500].include?('<html') && data[0..1000].include?('<head>'))
      File.delete(v.image.path)
      v[:img] = v.mal
      v.grab_mal_image(true)
    end
  end
  #add_transaction_tracer :check_broken, :category => :task
end

class MalTasks
  def import(anime_id)
    animes = [anime_id]

    parser = MalParser.new
    parser.init_saver
    parser.cache[:animes][anime_id][:imported] = DateTime.now - 2.weeks
    parser.fetch_animes(true, animes)
    parser.fetch_characters(true, animes)
    parser.fetch_people(true, animes)
    parser.apply_fixes
    parser = nil
    GC.start
  end
  #add_transaction_tracer :import, :category => :task

  def import_all
    parser = MalParser.new
    parser.init_saver
    parser.fetch_animes_list
    parser.fetch_animes(true)
    parser.fetch_characters(true)
    parser.fetch_people(true)
    parser.apply_fixes
    parser = nil
    GC.start
  end
  #add_transaction_tracer :import_all, :category => :task

  def import_new
    parser = MalParser.new
    parser.init_saver
    parser.reset_pages_to_parse
    parser.fetch_animes_list
    parser.fetch_animes
    parser.fetch_characters
    parser.fetch_people
    parser.apply_fixes
    parser = nil
    GC.start
  end
  #add_transaction_tracer :import_new, :category => :task

  def import_anons
    animes = Anime.anons.map {|v| v.id }

    parser = MalParser.new
    parser.init_saver
    parser.fetch_animes(true, animes)
    parser.fetch_characters(true, animes)
    parser.fetch_people(true, animes)
    parser.apply_fixes
    parser = nil
    GC.start
  end
  #add_transaction_tracer :import_anons, :category => :task

  def import_ongoing
    animes = Anime.ongoing.map {|v| v.id }

    parser = MalParser.new
    parser.init_saver
    parser.fetch_animes(true, animes)
    parser.fetch_characters(true, animes)
    parser.fetch_people(true, animes)
    parser.apply_fixes
    parser = nil
    GC.start
  end
  #add_transaction_tracer :import_ongoing, :category => :task

  def import_latest
    animes = Anime.latest.map {|v| v.id }

    parser = MalParser.new
    parser.init_saver
    parser.fetch_animes(true, animes)
    parser.fetch_characters(true, animes)
    parser.fetch_people(true, animes)
    parser.apply_fixes
    parser = nil
    GC.start
  end
  #add_transaction_tracer :import_latest, :category => :task

  def deploy(anime_id)
    deploy_by_id([anime_id], false)
  end
  #add_transaction_tracer :deploy, :category => :task

  def deploy_new
    deploy_by_id(Anime.select(:id).all.map(&:id), true)
  end
  #add_transaction_tracer :deploy_new, :category => :task

  def deploy_all
    block_num = 0
    animes = Anime.select(:id).all.map(&:id)
    print "total blocks num - %d\n" % [animes.size / 200]
    animes.each_slice(200) do |block|
      print "fetching block %d...\n" % [block_num]
      block_num += 1 and next if Rails.cache.exist?('mal_deploy_all') && Rails.cache.read('mal_deploy_all') >= block_num
      deploy_by_id(block, false)
      Rails.cache.write('mal_deploy_all', block_num)
      block_num += 1
    end
    Rails.cache.delete('mal_deploy_all')
  end
  #add_transaction_tracer :deploy_all, :category => :task

  def deploy_anons
    deploy_by_id(Anime.anons.select(:id).all.map(&:id), false)
  end
  #add_transaction_tracer :deploy_anons, :category => :task

  def deploy_ongoing
    deploy_by_id(Anime.ongoing.select(:id).all.map(&:id), false)
  end
  #add_transaction_tracer :deploy_ongoing, :category => :task

  def deploy_latest
    deploy_by_id(Anime.latest.map(&:id), false)
  end
  #add_transaction_tracer :deploy_latest, :category => :task

private
  def deploy_by_id(animes_ids, except)
    parser = MalParser.new
    parser.apply_fixes
    parser.cache[:animes].delete_if {|k,v| except ? animes_ids.include?(k) : !animes_ids.include?(k) }

    Anime.import(:all, parser.cache)

    characters_ids = parser.cache[:animes].map {|k,v| v[:characters].map {|k,v| v[:id] } }.flatten.uniq
    parser.cache[:characters].delete_if {|k,v| !characters_ids.include?(k) }

    Character.import(:all, parser.cache, :link_all)

    animes_staff = parser.cache[:animes].map {|k,v| v[:people].map {|k,v| v[:id] } }
    characters_staff = parser.cache[:characters].map {|k,v| v[:staff].map {|v| v[:id] } }
    people_ids = (animes_staff + characters_staff).flatten.uniq
    parser.cache[:people].delete_if {|k,v| !people_ids.include?(k) }

    Person.import(:all, parser.cache, :link_all)

    AnimeImage.import(parser.cache)
    parser = nil

    GC.start
  end
end
