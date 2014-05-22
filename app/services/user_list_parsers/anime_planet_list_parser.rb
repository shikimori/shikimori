# парсер JSON'а, приходящего из яваскриптовского парсера MAL'а
class UserListParsers::AnimePlanetListParser
  def initialize klass
    @klass = klass
    @matcher = NameMatcher.new @klass
  end

  def parse login
    1.upto(pages_count(login)).map do |page|
      find_matches parse_page login, page
    end.flatten
  end

private
  # заполнение id для собранного списка
  def find_matches entries
    entries.each do |entry|
      entry[:id] = find_match entry
    end
  end

  # получение id для найденного элемента
  def find_match entry
    matches = @matcher.matches entry[:name], year: entry[:year]
    matches.first.id if matches.one? && entry[:status]
  end

  # получение списка того, что будем импортировать
  def parse_page login, page
    content = get("http://www.anime-planet.com/users/#{login}/#{@klass.name.downcase}/all?page=#{page}")
    doc = Nokogiri::HTML(content)

    doc.css('.entryTable tr:has(td)').map do |tr|
      {
        name: tr.css('.tableTitle').first.text.gsub(/^(.*), The$/, 'The \1'),
        status: convert_status(tr.css('.tableStatus').first.text.strip),
        score: tr.css('.tableRating img').first.attr('name').to_f*2,
        year: tr.css('.tableYear').first.text.to_i,
      }.merge(@klass == Anime ? {
        episodes: tr.css('.tableEps').first.text.to_i
      } : {
        volumes: tr.css('.tableVols').first.text.to_i,
        chapters: tr.css('.tableCh').first.text.to_i
      })
    end
  end

  # получение общего числа страниц списка
  def pages_count login
    content = get("http://www.anime-planet.com/users/#{login}/#{@klass.name.downcase}/all?page=1")
    doc = Nokogiri::HTML(content)

    @pages = doc
      .css('.pagination li')
      .map {|link| link.text.to_i }
      .max
  end

  # переведение статус из анимепланетного в локальный
  def convert_status planet_status, wont_watch_strategy=nil
    case planet_status
      when 'Watched', 'Read'
        UserRate.statuses[:completed]

      when 'Watching', 'Reading'
        UserRate.statuses[:watching]

      when 'Want to Watch', 'Want to Read'
        UserRate.statuses[:planned]

      when 'Stalled'
        UserRate.statuses[:on_hold]

      when 'Dropped'
        UserRate.statuses[:dropped]

      when "Won't Watch", "Won't Read"
        wont_watch_strategy

      else
        raise ArgumentError.new(planet_status)
    end
  end

  # загрузка страницы через прокси
  def get url
    content = Proxy.get url, timeout: 30, required_text: 'Anime-Planet</title>'
    raise EmptyContent, url unless content
    raise InvalidId, url if content.include?("You searched for")
    content
  end
end
