#require 'progressbar'
#class CosRainParser < SiteParserWithCache
  #alias :super_load_cache :load_cache

  #INDEX_URL = "http://www.cosrain.com/search?max-results=9999"
  #NEXT_PAGE_REGEXP = /<a class='blog-pager-older-link' href='([^']+)' id='Blog1_blog-pager-older-link' title='Next Page'>Next Page<\/a>/
  #ENTRY_REGEXP = /<h3 class='post-title entry-title'.*?>\s+<a href='([^']+)' target='_blank' title='([^']+)'>/
  #ALLOWED_TYPES = [
    #'CosplaySession',
    #'CosplayerEveryDay',
    #'CosplayerProfile',
    #'CosplayEvent',
    #'CosplayOther'
  #]
  ##SKIP_TYPES = [
    ##'video',
    ##'cosplay video',
    ##'photo',
    ##'photo album',
    ##'sexy photo album',
    ##'new photo'
  ##]
  #IDS_MAP = {
    #'Kipi in Wuhan (2010/06/25)' => 'Kipi＇s Every Day (2010/06/25)',
    #'Kipi in Wuhan (2010/06/23)' => 'Kipi＇s Every Day (2010/06/23)',
    #'Kipi in Wuhan (2010/06/22)' => 'Kipi＇s Every Day (2010/06/22)',
    #'Dream Club Cosplay (2010/06/01)' => 'Anonymouse＇s COSPLAY - Dream Club (2010/06/01)',
    #'Japanese Sexy Maid (2010/06/24)' => 'Anonymouse＇s COSPLAY - Maid (2010/06/24)',
    #'Japanese Sexy Maid (2010/07/08)' => 'Anonymouse＇s COSPLAY - Maid (2010/07/08)',
    #'12th ACGHK 2010 (2010/07/31)' => 'Anonymouse＇s EVENT - 12th ACGHK 2010 (2010/07/31)',
    #'12th ACGHK 2010 (2010/08/02)' => 'Anonymouse＇s EVENT - 12th ACGHK 2010 (2010/08/02)',
    #'C79 Day 1 (2010/12/29)' => 'Anonymouse＇s EVENT - C79 (2010/12/29)',
    #'Wonder Festival Winter 2010 Cosplay Collection' => 'Anonymouse＇s EVENT - Wonder Festival 2010 (2010/02/07)',
    #'2010 Animation Festival (2010-07-28)' => 'Anonymouse＇s EVENT - Animation Festival 2010 (2010/07/28)',
    #'TOKYO GAME SHOW 2010' => 'Anonymouse＇s EVENT - Tokyo Game Show 2010 (2010/09/19)',
    #'TOKYO GAME SHOW 2010 SHOW GIRLS' => 'Anonymouse＇s EVENT - Tokyo Game Show 2010 (2010/09/22)'
  #}
  #TYPES_MAP = {
    #'cosplay'      => 'CosplaySession',
    #'new cosplay'  => 'CosplaySession',
    #'maid cosplay' => 'CosplaySession',
    #'sexy cosplay' => 'CosplaySession',
    #'profile'      => 'CosplayerProfile',
    #'event'        => 'CosplayEvent',
    #'every day'    => 'CosplayerEveryDay'
  #}
  #SKIP_IDS = [
    #"Aira＇s COSPLAY VIDEO - AFA X (2010/11/19)",
    #"Kipi＇s COSPLAY VIDEO - Kasumi (2010/03/06)",
    #"Kipi＇s VIDEO - Kipi in Chiang Mai (2011/06/12)",
    #"Kipi＇s VIDEO (2010/03/04)",
    #"Kipi＇s COSPLAY VIDEO - Kasumi (2010/03/05)",
    #"Kipi＇s VIDEO - Wuhan ComiAi 3 (2010/12/21)",
    #"Kipi＇s COSPLAY VIDEO - K-On!  (2011/06/12)",
    #"Kipi＇s VIDEO - Comic Party 26th in Chiangma (2011/05/23)",
    #"KIPI＇s VIDEO - PLAY WII GAME (2010/10/08)",
    #"Kipi＇s VIDEO - 2010 Wuhan University International Cultural Festival (2010/11/24)",
    #"Kipi＇s COSPLAY VIDEO - Mahou Shoujo Madoka Magica  (2011/06/13)"
    ##'Aoi Sola in Shanghai＇Online Games Live (2010/06/18)',
    ##'Chrissie Chau @ 12th ACGHK 2010 (2010/08/02)',
    ##'Kipi & Saya & Mishin Tsugihagi (2010/08/22)',
    ##'Kipi in WF2011 Winter (2011/02/07)'#,
    ###'DORAEMON＇s COSPLAY (2010/01/05)'
  #]

  ## конструктор
  #def initialize
    #super
    #@required_text = 'CosRain'
    #@proxy_log = false
  #end

  ## сохранение кеша
  #def load_cache
    #super_load_cache

    #if @cache[:store] == nil
      #@cache[:store] = {}
    #end
    #print "cache loaded\n" if Rails.env != 'test'
    #@cache
  #end

  ## загрузка всех страниц сайта с ссылками на записи косплея
  #def fetch_links
    #url = INDEX_URL
    #Proxy.use_cache = false
    #begin
      #begin
        #url = fetch_page(url)
      #end while url
    #rescue Exception => e
      #ap e
    #end
    #Proxy.use_cache = true
    #save_cache
  #end

  ## загрузка страницы сайта с ссылками на записи косплея
  #def fetch_page(url)
    #content = open(url).read
    #print "[open]: #{url}\n"
    #return nil unless content

    #entries = 0
    #content.gsub(ENTRY_REGEXP).each do |line|
      #url = $1
      #id = $2

      #if id.downcase.include?('doraemon')
        #print "skipped doraemon id: %s\n" % [id]
        #next
      #end
      #id = IDS_MAP[id] if IDS_MAP.keys.include?(id)
      #if SKIP_IDS.include?(id)
        #print "skipped id: %s (%s)\n" % [id, url]
        #next
      #end

      #unless id.match /(.*?)＇(?:s )?(.*?) - ?(.*?) ?\((\d+)\/(\d+)\/(\d+)\)/
        #unless id.match /(.*?)＇(?:s )?(.*?)( )\((\d+)\/(\d+)\/(\d+)\)/
          #if id.match /(.*?)＇s (Profile)/
          #elsif id.match /(.*?) (.*?)( )\((\d+)\/(\d+)\/(\d+)\)/
            #print "warn: %s (%s)\n" % [id, url]
          #else
            #print "skipped cant parse: %s (%s)\n" % [id, url]
            #next
          #end
        #end
      #end
      #type = $2.downcase.strip
      #type = TYPES_MAP[type] if TYPES_MAP.keys.include?(type)
      #entry = {
        #id: id,
        #name: $1.downcase,
        #type: type,
        #target: $3 ? $3.strip : '',
        #url: url,
        #date: $4 && $5 && $6 ? Date.new($4.to_i, $5.to_i, $6.to_i) : nil
      #}
      #entry[:name] = entry[:name].gsub(/\./, ' ').strip.split(/☆|&/).map {|v| v.strip.split(' ').map {|part| part.capitalize }.join(' ') }
      #unless @cache[:store].include?(id)
        ##if SKIP_TYPES.include?(entry[:type])
          ##print "skipped type: %s (%s)\n" % [id, url]
          ##next
        ##end
        #unless ALLOWED_TYPES.include?(entry[:type])
          #entry[:type] = ALLOWED_TYPES.last
          ##ap entry
        #end
        #@cache[:store][id] = entry
        #entries += 1
      #end
    #end
    #print "found %d new entries\n" % entries
    #if content.match(NEXT_PAGE_REGEXP) && entries > 0
      #URI.decode($1).gsub('&amp;', '&').gsub('+', '%2B')
    #else
      #nil
    #end
  #end

  #def fetch_entries
    #store = @cache[:store].select {|k,v| v[:description] == nil || v[:images] == nil || v[:images].empty? }
    #pbar = ProgressBar.new("fetching entries", store.size)
    #store.each do |id,entry|
    ##@cache[:store].select {|k,v| v[:id] == 'Aira＇s COSPLAY - The Prince of Tennis (2011/05/05)' }.each do |id,entry|
      #if SKIP_IDS.include?(id)
        #print "skipped id: %s (%s)\n" % [id, entry[:url]]
        #next
      #end
      #content = Proxy.get(entry[:url],
                          #timeout: 30,
                          #required_text: @required_text,
                          #ban_texts: MalFetcher.ban_texts,
                          #log: @proxy_log,
                          #no_proxy: true)
      #unless content
        #pbar.inc
        #next
      #end

      #content = content.sub(/[\s\S]*<div class='postpage'[^>]+>([\s\S]*?)<\/div>[\s\S]*/, '\1').
                        #sub(/[\s\S]*<a name='more'><\/a>/, '').
                        #gsub('<br />', '').
                        #strip
      #entry[:description] = content.gsub(/<[^>]+?>/, '')
      #entry[:images] = content.gsub(/<img\s+src=(?:"|')([^"']+)(?:"|')/).map { $1 }
      #ap entry if entry[:images].empty?
      ##ap entry
      #pbar.inc
    #end
    #pbar.finish
    #save_cache
  #end

  ## слияние данных из кеша с данными в базе
  #def merge_with_database
    ## импорт персонажей
    #print "fetching cosplayers...\n"
    #added_cosplayers = {}
    #data = @cache[:store].
            ##select {|k,v| k == 'Kipi＇s COSPLAY - Original Character:Valentine (2011/04/03)' }.
            #map {|k,v| v }.group_by {|v| v[:name].first }.map {|k,v| v }.sort_by {|v| v.size * -1 }
    #data.each do |group|
      #name = group.first[:name].first
      #next if added_cosplayers.keys.include?(name)
      #added_cosplayers[name] = Cosplayer.find_or_create_by_name(:name => name)
    #end
    #@cache[:store].map {|k,v| v[:name] }.flatten.uniq.sort.each do |name|
      #next if added_cosplayers.keys.include?(name)
      #added_cosplayers[name] = Cosplayer.find_or_create_by_name(:name => name)
    #end
    #print "fetched #{added_cosplayers.size} cosplayers\n"

    ## импорт галерей
    #added_galleries = 0
    #pbar = ProgressBar.new("fetching cosplay galleries", @cache[:store].size)
    #data.each do |group|
      #next unless group
      #group.each do |entry|
        #gallery = CosplayGallery.find_or_create_by_cos_rain_id(entry[:id])
        #next if gallery.confirmed
        #next unless gallery.created_at + 30.days > DateTime.now
        #gallery.type = entry[:type]
        #gallery.date = entry[:date]
        #gallery.target = entry[:target]
        #gallery.description_cos_rain = entry[:description]
        #gallery[:source] = CosplayGallerySource::CosRain
        #gallery.save
        #entry[:name].each do |cosplayer_name|
          #CosplayGalleryLink.find_or_create_by_linked_id_and_linked_type_and_cosplay_gallery_id(
              #added_cosplayers[cosplayer_name].id,
              #added_cosplayers[cosplayer_name].class.name,
              #gallery.id
            #)
        #end

        #if entry[:images]
          #pos = 0
          #entry[:images].each do |url|
            #image = CosplayImage.find_by_url(url)
            #pos += CosplayImage::PositionStep

            #unless image
              #image = CosplayImage.create(url: url)
              ##image_file_name = image.id.to_s + File.extname(url)
              ##dir = Rails.root.to_s + '/public/images/' + image.class.name.downcase + '/original/'
              ##if File.exists?(dir+image_file_name)
                ##File.delete(dir+image_file_name)
                ##print "deleted image %s\n" % [dir+image_file_name]
              ##end
              #if image.image.exists?
                #File.delete(image.image.path(:original))
                #print "deleted image %s\n" % [image.image.path(:original)]
              #end
            #else
              ##image_file_name = image.id.to_s + File.extname(url)
              ##dir = Rails.root.to_s + '/public/images/' + image.class.name.downcase + '/original/'
              ##next if File.exists?(dir+image_file_name)
              #next if image.image.exists?
            #end

            #image.position = pos
            #image.cosplay_gallery_id = gallery.id
            #image.image = open_image(image.url)
            #image.save
          #end
        #end

        #added_galleries += 1
        #pbar.inc
      #end
    #end
    #pbar.finish
    #print "fetched #{added_galleries} galleries\n"
  #end

  ## очистка базы от мусора
  #def clean_database
    ## чистка сломанных изображений
    #images = CosplayImage.where(:deleted => false).all
    #pbar = ProgressBar.new("checking broken images", images.size)
    #images.each do |v|
      #unless v.image.exists? && File.exists?(v.image.path)
        ##ap v.image.path
        #v.destroy
        #pbar.inc
      #else
        #data = File.open(v.image.path, "r") {|h| h.gets }
        #pbar.inc
        #next unless data.starts_with?('<') || data == '\n' || data == "\n"
        ##ap v.image.path
        #v.destroy
      #end
    #end
    #pbar.finish

    ## чистка маленьких изображений
    #images = CosplayImage.where(:deleted => false).all
    #pbar = ProgressBar.new("checking small images", images.size)
    #images.each do |v|
      #next unless v.image.exists? && File.exists?(v.image.path)
      #begin
        #Timeout::timeout(5) do
          #geometry = Paperclip::Geometry.from_file(v.image.path)
          #if geometry.height <= 260 || geometry.width <= 260
            #print "deleted image %s\n" % v.image.path
            #v.update_attribute(:deleted, true)
          #end
        #end
      #rescue
      #end
      #pbar.inc
    #end
    #pbar.finish

    ## чистка пустых картинок, галерей, косплееров
    #print "deleted %d empty images\n" % CosplayImage.where(:image_file_name => nil, :deleted => false).each {|v| v.update_attribute(:deleted, true) }.count
    #print "deleted %d empty galleries\n" % CosplayGallery.joins('left join cosplay_images on cosplay_images.cosplay_gallery_id = cosplay_galleries.id and cosplay_images.deleted = false').
                                                          #where(:deleted => false).
                                                          #group(:id).
                                                          #having('count(cosplay_images.id)=0').
                                                            #all.
                                                            #each {|v| ap v and v.update_attribute(:deleted, true) }.
                                                              #count
  #end
#end
