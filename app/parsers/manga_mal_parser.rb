class MangaMalParser < BaseMalParser
  STATUSES = {
    'Not yet published' => 'anons',
    'Publishing' => 'ongoing',
    'Finished' => 'released',
    'Finished Airing' => 'released'
  }

  # сохранение уже импортированных данных
  def deploy entry, data
    ## для хентая ставим флаг censored
    entry.censored = data[:entry][:genres].any? do |genre|
      Genre::CENSORED_IDS.include? genre[:mal_id]
    end
    ## то, что стоит релизом, не сбрасывать назад в онгоинг при ипорте
    #data[:entry].delete(:status) if entry.released? &&
                                    #data[:entry][:status] == 'ongoing' &&
                                    #entry.episodes_aired == entry.episodes
    super entry, data
  end

  # загрузка всей информации по манге
  def fetch_entry id
    data = super
    data[:people] = data[:entry][:authors].inject({}) do |rez,v|
      rez[v[:id]] = {
        role: v[:role],
        id: v[:id]
      }
      rez
    end
    data
  end

  # загрузка информации по манге
  def fetch_entry_data id
    content = get entry_url(id)
    doc = Nokogiri::HTML(content)

    entry = {}

    entry[:name] = parse_h1(content)
    entry[:id] = id
    entry[:description_en] = parse_synopsis(content)

    #parse_block(entry, :related, /Related Manga?<\/h2>([\s\S]*?)(?:<h2>|<\/td>)/, content)
    entry[:related] = parse_related doc

    entry[:english] = parse_line("English", content, true)
    entry[:japanese] = parse_line("Japanese", content, true)
    entry[:synonyms] = parse_line("Synonyms", content, true)

    alt = entry[:name].permalinked.gsub(/-/, ' ').titleize
    entry[:synonyms] = entry[:synonyms] + [alt] unless entry[:name] == alt || entry[:synonyms].include?(alt)

    entry[:kind] = parse_line('Type', content, false)
      .downcase
      .gsub(/ |-/, '_')
      .sub('doujinshi', 'doujin')
      .sub('unknown', '')
      .gsub(/<.*?>/, '')

    entry[:volumes] = parse_line("Volumes", content, false).to_i
    entry.delete(:volumes) if entry[:volumes] == 0
    entry[:chapters] = parse_line("Chapters", content, false).to_i
    entry.delete(:chapters) if entry[:chapters] == 0

    entry[:status] = STATUSES[parse_line("Status", content, false)]
    dates = parse_line("Published", content, false).split(' to ').map do |v|
      parse_date(v)
    end
    entry[:released_on] = dates.size == 2 ? dates[1] : nil
    entry[:aired_on] = dates[0]

    entry[:genres] = parse_line("Genres", content, true)
      .map do |line|
        {
          mal_id: $1.to_i,
          name: $2,
          kind: 'manga',
        } if line.match /genre\/(\d+).*>(.*)<\/a>/
      end
      .select(&:present?)

    entry[:authors] = parse_line("Authors", content, false).split('),')
      .map do |line|
        {
          id: $1.to_i,
          name: $2,
          role: $3,
        } if line.match /people\/(\d+).*>(.*)<\/a> \(([^\)]*)\)?/
      end
      .select(&:present?)

    entry[:publishers] = parse_line("Serialization", content, true)
      .map do |line|
        {
          id: $1.to_i,
          name: $2
        } if line =~ /magazine\/(\d+).*>(.*)<\/a>/
      end
      .select(&:present?)


    #entry[:rating] = parse_line("Rating", content, false)
    entry[:score] = parse_score(content)
    entry[:ranked] = parse_ranked(content)
    entry[:popularity] = parse_line("Popularity", content, false).match(/(\d+)/) ? $1.to_i : 0
    entry[:members] = parse_line("Members", content, false).gsub(",", "").to_i
    entry[:favorites] = parse_line("Favorites", content, false).gsub(",", "").to_i

    doc = Nokogiri::HTML(content)
    img_doc = doc.css("td.borderClass > div > img")

    if img_doc.empty? || img_doc.first.attr(:src) !~ %r{cdn.myanimelist.net}
      entry[:img] = doc.css("td.borderClass > div > div > a > img, td.borderClass > div > a > img").first.attr(:src)
    else
      entry[:img] = img_doc.first.attr(:src)
    end

    raise EmptyContent.new(url) if entry[:english].blank? && entry[:score].blank? && entry[:synonyms].blank? && entry[:name].blank? &&
                                   entry[:status].blank? && entry[:kind].blank? && entry[:ranked].blank?

    entry
  end
end
