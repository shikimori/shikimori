class BaseMalParser < SiteParserWithCache
  include MalFetcher
  include MalDeployer

  EntriesPerPage = 20
  RelatedAdaptationName = "Adaptation"

  # инициализация кеша
  def load_cache
    super
    @cache[:list] = {} unless @cache.include? :list
  end

  def genres
    @genres ||= Genre.all.inject({}) do |rez,v|
      rez[v.id] = v
      rez
    end
  end

  def studios
    @studios ||= Studio.all.inject({}) do |rez,v|
      rez[v.id] = v
      rez
    end
  end

  def publishers
    @publishers ||= Publisher.all.inject({}) do |rez,v|
      rez[v.id] = v
      rez
    end
  end

  # список
  def list
    @cache[:list]
  end

  # список параметров элементов, заданных руками
  def mal_fixes
    unless @mal_fixes
      all_mal_fixes = YAML::load(File.open("#{::Rails.root.to_s}/config/mal_fixes.yml"))
      @mal_fixes = all_mal_fixes.include?(type.to_sym) ? all_mal_fixes[type.to_sym] : {}
    end
    @mal_fixes
  end

  # применение правок для импортированных данных
  def apply_mal_fixes(id, data)
    mal_fixes[id].each do |k2,v2|
      #if data[:entry][k2].respond_to?('merge!')
        #data[:entry][k2].merge!(v2)
      #else
        #data[:entry][k2] = v2
      #end
      data[:entry][k2] = v2
    end if mal_fixes.include?(id)
    data
  end

  def self.import(ids=nil)
    self.new.import(ids)
  end

  # импорт всех новых и помеченных к импорту элементов
  def import(ids=nil)
    Proxy.preload
    ThreadPool.defaults = { threads: 60 }# timeout: 90, log: true debug_log: true }
    #@proxy_log = true
    @import_mutex = Mutex.new

    klass = Object.const_get(type.camelize)

    print "loading %s for import\n" % [type.tableize] if Rails.env != 'test'
    # если передан id, то импортировать только элемент с указанным id
    data = ids ? (ids.kind_of?(Enumerable) ? ids : [ids]) : prepare

    print "%d %s to import\n" % [data.size, type.tableize] if Rails.env != 'test'
    data.send(Rails.env == 'test' ? :each : :parallel) do |id|
      begin
        print "downloading %s %s\n" % [type, id] if Rails.env != 'test'
        fetched_data = fetch_entry(id)

        # применение mal_fixes
        apply_mal_fixes(id, fetched_data)

        entry = klass.find_or_create_by(id: id)
        @import_mutex.synchronize do
          print "deploying %s %s %s\n" % [type, id, entry.name] if Rails.env != 'test'
          deploy(entry, fetched_data)
        end
        print "successfully imported %s %s %s\n" % [type, id, entry.name] if Rails.env != 'test'
      rescue Exception => e
        print "%s\n%s\n" % [e.message, e.backtrace.join("\n")] if Rails.env == 'test' || e.class != EmptyContent
        print "failed import for %s %s\n" % [type, id] if Rails.env != 'test'
        exit if e.class == Interrupt
      end
    end
  end

  # сбор списка элементов, которые будем импортировать
  def prepare
    imported = {}
    ActiveRecord::Base.connection.
        execute("select id,imported_at from #{type.tableize}"). # #{' where id not in (8757, 8758, 8759, 8760, 17653)' if type.tableize == 'animes'}
          each {|v| imported[v['id'].to_i] = v['imported_at'].nil? ? nil : v['imported_at'].to_datetime }

    new_ids = list.keys - imported.keys
    outdated_ids = imported.select {|k,v| v.nil? }.map {|k,v| k }

    new_ids + outdated_ids
  end

  # загрузка полного списка с MAL
  def fetch_list_pages(options = {})
    options = { offset: 0, limit: 99999, url_getter: :all_catalog_url }.merge(options)
    #total_entries_found = 0
    page = options[:offset]
    all_found_entrires = []

    begin
      entries_found = fetch_list_page(page, options[:url_getter])
      all_found_entrires += entries_found
      #total_entries_found += entries_found
      page += 1 if entries_found.any?
    rescue Exception => e
      print "%s\n%s\n" % [e.message, e.backtrace.join("\n")]
      break
    end while entries_found.any? && page < options[:limit]
    #total_entries_found
    save_cache
    all_found_entrires
  end

  # загрузка страницы списка
  def fetch_list_page(page, url_getter)
    max_attempts = 5
    entries_found = []
    attempt = 0

    url = self.send(url_getter, page)
    begin
      attempt += 1
      content = get(url, 'Search Results')
      next unless content
      doc = Nokogiri::HTML(content)

      doc.css("div#content > div > table tr").each do |tr|
        next unless tr.css('.normal_header').size.zero?
        tds = tr.css('td')
        entry = {}
        entry[:img_preview] = tds[0].css('img')[0]['src']
        entry[:url] = tds[1].css('a')[0]['href']
        entry[:id] = entry[:url].match(/\/(\d+)\//)[1].to_i
        entry[:name] = tds[1].css('a > strong')[0].inner_html

        list[entry[:id]] = entry
        entries_found << entry[:id]
      end

      break if entries_found.any?
    end while attempt < max_attempts

    if entries_found.empty?
      print "page %i fetched successfully, but found 0 entries\n" % page
    else
      print "page %i fetched successfully, found %i entries\n" % [page, entries_found.size]
    end unless Rails.env == 'test'

    entries_found
  end

private
  # получение страницы MAL
  def get(url, required_text=['MyAnimeList.net</title>', '</html>'])
    content = super(url, required_text)
    raise EmptyContent.new(url) unless content
    raise InvalidId.new(url) if content.include?("Invalid ID provided") ||
                                content.include?("No manga found, check the manga id and try again") ||
                                content.include?("No series found, check the series id and try again")
    raise ServerUnavailable.new(url) if content.include?("MyAnimeList servers are under heavy load")
    content
  end

  def updated_catalog_url(page)
    "http://myanimelist.net/#{type}.php?o=9&c[]=a&c[]=d&cv=2&w=1&show=#{page * EntriesPerPage}"
  end

  def all_catalog_url(page)
    "http://myanimelist.net/#{type}.php?letter=&q=&tag=&sm=0&sd=0&em=0&ed=0&c[0]=b&c[1]=c&c[2]=a&show=#{page * EntriesPerPage}"
  end

  def entry_url(id)
    "http://myanimelist.net/#{type}/#{id}"
  end

  def type
    @type ||= self.class.name.match(/[A-Z][a-z]+/)[0].downcase
    @type
  end
end
