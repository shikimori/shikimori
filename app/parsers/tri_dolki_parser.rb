require 'progressbar'

class TriDolkiParser < SiteParserWithCache
  alias :super_load_cache :load_cache

  INDEX_URL = "http://www.tridolki.com/load/gallery/4-%d-2"
  ENTRY_REGEXP = /<b><span style="color: black;"><span style="font-size: 10pt;"><a href="([^"]+)/i
  IMAGE_REGEXP = /<div align="?center"?><img (?:alt="[^"]+" )?src="([^"]+)/i

  # конструктор
  def initialize
    super
    @required_text = 'TriDolki'
    @proxy_log = false
  end

  # сохранение кеша
  def load_cache
    super_load_cache

    if @cache[:store] == nil
      @cache[:store] = {}
    end
    print "cache loaded\n" if Rails.env != 'test'
    @cache
  end

  # загрузка всех страниц сайта с ссылками на записи косплея
  def fetch_links
    page = 1
    begin
      begin
        fetched_items = fetch_page(INDEX_URL % page)
        page += 1
        sleep 1
      end while fetched_items > 0
    rescue Exception => e
      ap e
    end
    save_cache
  end

  # загрузка страницы сайта с ссылками на записи косплея
  def fetch_page(url)
    content = Proxy.get(url, timeout: 30, required_text: @required_text, ban_texts: MalFetcher.ban_texts, log: @proxy_log, no_proxy: true)
    return nil unless content

    entries = 0
    content.gsub(ENTRY_REGEXP).each do |line|
      id = $1.sub('http://www.', 'http://')

      unless @cache[:store].include?(id)
        @cache[:store][id] = nil
        entries += 1
      end
    end
    print "found %d new entries in page %s\n" % [entries, url]
    entries
  end

  # парсинг страниц сайта
  def fetch_entries
    store = @cache[:store].select {|k,v| (v == nil || v[:images].empty?) && k.include?('cosplay') }
    pbar = ProgressBar.new("fetching entries", store.size)
    store.each do |id,entry|
      fetch_entry(id)
      pbar.inc
      sleep 1
    end
    pbar.finish
    save_cache
  end

  # парсинг страницы сайта
  def fetch_entry(id)
    content = Proxy.get(id, timeout: 30, required_text: @required_text, ban_texts: MalFetcher.ban_texts, log: @proxy_log, no_proxy: true)
    return unless content

    entry = nil
    if content =~ /Косплеер: <(?:b.*?|span.*?)>(.*?)<\/(?:b|span)>.*?Персонаж: <(?:b.*?|span.*?)>(.*?)<\/(?:b|span)>.*?(?:Откуда|Аниме): ~?<(?:b.*?|span.*?)>(.*?)<\/(?:b|span)>/i
      entry = {
        :name => $1.strip,
        :target => $2.strip,
        :anime => $3.strip,
        :description => "#{$1.strip} is cosplaying as #{$2.strip} from #{$3.strip}.",
        :url => id,
        :type => 'CosplaySession',
        :images => [],
      }
      #ap entry
      if content =~ /<td align="right" style="font-size:7pt;white-space: nowrap;">(\d+) (\w+) (\d+)/
        year = '20%d' % $3
        entry[:date] = DateTime.parse("%d %s %d" % [$1.to_i,
                                                    $2.sub('Декабрь', 'December').
                                                        sub('Январь', 'January').
                                                        sub('Февраль', 'February').
                                                        sub('Март', 'Marth').
                                                        sub('Апрель', 'April').
                                                        sub('Май', 'May').
                                                        sub('Июнь', 'June').
                                                        sub('Июль', 'July').
                                                        sub('Август', 'August').
                                                        sub('Сентябрь', 'September').
                                                        sub('Октябрь', 'October').
                                                        sub('Ноябрь', 'November'),
                                                    year])
      end
      entry[:date] = DateTime.now if entry[:date] == nil
      @cache[:store][id] = entry

      content.gsub(IMAGE_REGEXP).each do |line|
        next if line.include?('/1.jpg')
        entry[:images] << $1
      end
    end
    #ap entry
    print "found %d images on %s\n" % [entry ? entry[:images].size : 0, id]
  end

  # слияние данных из кеша с данными в базе
  def merge_with_database
    # импорт персонажей
    print "fetching cosplayers...\n"
    added_cosplayers = {}

    @cache[:store].each do |k,v|
      next unless v
      @cache[:store][k][:name] = v[:name] ? v[:name].gsub(/^~$/, 'Japanese Girl').
                                                     gsub(/^-$/, 'Japanese Girl').
                                                     gsub(/^$/, 'Japanese Girl') :
                                            'Japanese Girl'
    end
    data = @cache[:store].
            select {|k,v| v }.map {|k,v| v }.group_by {|v| v[:name] }.map {|k,v| v }.sort_by {|v| v.size * -1 }
    data.each do |group|
      name = group.first[:name]
      next if added_cosplayers.keys.include?(name)
      added_cosplayers[name] = Cosplayer.find_or_create_by_name(:name => name)
    end
    print "fetched #{added_cosplayers.size} cosplayers\n"

    # импорт галерей
    added_galleries = 0
    pbar = ProgressBar.new("fetching cosplay galleries", @cache[:store].size)
    data.each do |group|
      next unless group
      group.each do |entry|
        gallery = CosplayGallery.find_or_create_by_cos_rain_id(entry[:url])
        if gallery.confirmed
          pbar.inc
          next
        end
        #next unless gallery.created_at + 30.days > DateTime.now
        gallery.type = entry[:type]
        gallery.date = entry[:date]
        gallery.target = entry[:target]
        gallery.description_cos_rain = entry[:description]
        gallery[:source] = CosplayGallerySource::TriDolki
        gallery.save
        cosplayer_name = entry[:name]
        CosplayGalleryLink.find_or_create_by_linked_id_and_linked_type_and_cosplay_gallery_id(
            added_cosplayers[cosplayer_name].id,
            added_cosplayers[cosplayer_name].class.name,
            gallery.id
          )

        #ap entry[:images]
        if entry[:images]
          entry[:images].each do |url|
            image = CosplayImage.where(:url => url).all.select {|v| v.cosplay_gallery_id == gallery.id }.first
            #if image.cosplay_gallery_id != gallery.id
              #print "gallery: #{gallery.id}, image: #{url} is regisered for another gallery: #{image.cosplay_gallery_id}\n"
            #end
            unless image
              image = CosplayImage.create(:url => url)
              if image.image.exists?
                File.delete(image.image.path(:original))
                print "deleted image %s\n" % [image.image.path(:original)]
              end
            else
              if image.image.exists?
                next
              end
            end

            #image[:img] = image.url
            image[:cosplay_gallery_id] = gallery.id

            begin
              io = open(image.url)
              def io.original_filename; base_uri.path.split('/').last; end

              image.image = (io.original_filename.blank? ? nil : io)
              image.save
            rescue Exception => e
              exit if e.class == Interrupt
              ap e
            end
          end
        end

        added_galleries += 1
        pbar.inc
      end
    end
    pbar.finish
    print "fetched #{added_galleries} galleries\n"
  end
end
