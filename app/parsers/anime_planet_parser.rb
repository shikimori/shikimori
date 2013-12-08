# импортёр аниме/манги списка с Anime-Planet
class AnimePlanetParser < SiteParserWithCache
  include AniMangaListImporter

  alias :super_fix_name :fix_name

  # логин пользователя
  attr_accessor :nickname

  # число странц в списке пользователя
  attr_accessor :pages

  # список с именами импортированных элементов
  attr_accessor :imported

  # список с именами импортированных элементов
  attr_accessor :not_imported

  # список с именами импортированных элементов
  attr_accessor :updated

  # список с именами не найденных элементов
  attr_accessor :not_matched

  # конструктор
  def initialize(nickname, klass)
    @klass = klass
    @nickname = nickname

    @imported = []
    @updated = []
    @not_imported = []
    @not_matched = []

    @no_proxy = true
  end

  # получение списка того, что будем импортировать
  def get_list
    1.upto(@pages).map do |page|
      content = get("http://www.anime-planet.com/users/#{@nickname}/#{@klass.name.downcase}/all?page=#{page}")
      doc = Nokogiri::HTML(content)
      doc.css('.entryTable tr:has(td)').map do |tr|
        {
          name: tr.css('.tableTitle').first.text.gsub(/^(.*), The$/, 'The \1'),
          status: tr.css('.tableStatus').first.text.strip,
          score: tr.css('.tableRating img').first.attr('name').to_f*2,
        }.merge(@klass == Anime ? {
          episodes: tr.css('.tableEps').first.text.to_i
        } : {
          volumes: tr.css('.tableVols').first.text.to_i,
          chapters: tr.css('.tableCh').first.text.to_i
        })
      end
    end.flatten
  end

  # получение общего числа страниц списка
  def get_pages_num
    content = get("http://www.anime-planet.com/users/#{@nickname}/#{@klass.name.downcase}/all?page=1")
    doc = Nokogiri::HTML(content)

    @pages = doc.css('.pagination li').map do |link|
      link.text.to_i
    end.max
  end

  # импорт списка
  def import_list user, list, rewrite_existed, wont_watch_strategy
    matcher = NameMatcher.new(@klass)

    # обход полного списка для импорта
    prepared_list = list.map do |entry|
      entry_status = convert_status(entry[:status], wont_watch_strategy)
      matches = matcher.matches entry[:name]

      if matches.size != 1 || (wont_watch_strategy.nil? && entry_status.nil?)
        @not_matched << entry[:name] unless entry_status.nil?
        next
      else
        entry.merge id: matches.first.id, status: entry_status
      end
    end.compact
    # дубликаты перемещаем в not_matched
    prepared_list.group_by {|v| v[:id] }.select {|k,v| v.size > 1 }.each do |id,group|
      group.each do |entry|
        @not_matched << entry[:name]
        prepared_list.delete entry
      end
    end

    @imported, @updated, @not_imported = import(user, @klass, prepared_list, rewrite_existed)

    [@imported, @updated, @not_matched]
  end

private
  def fix_name name
    super_fix_name(name).gsub(/([A-z])0(\d)/, '\1\2').gsub(/ /, '').gsub(/☆|†/, '').strip
  end

  # переведение статус из анимепланетного в локальный
  def convert_status planet_status, wont_watch_strategy=nil
    case planet_status
      when "Watched", "Read"
        UserRateStatus::Completed

      when "Watching", "Reading"
        UserRateStatus::Watching

      when "Want to Watch", "Want to Read"
        UserRateStatus::Planned

      when "Stalled"
        UserRateStatus::OnHold

      when "Dropped"
        UserRateStatus::Dropped

      when "Won't Watch", "Won't Read"
        wont_watch_strategy

      else
        raise ArgumentError.new(planet_status)
    end
  end

  # получение страницы с Anime-Planet
  def get url, required_text='Anime-Planet</title>'
    content = super(url, required_text)
    raise EmptyContent.new(url) unless content
    raise InvalidId.new(url) if content.include?("You searched for")
    #raise ServerUnavailable.new(url) if content.include?("MyAnimeList servers are under heavy load")
    content
  end
end
