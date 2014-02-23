class MangaMalParser < BaseMalParser
  # сохранение уже импортированных данных
  def deploy entry, data
    ## для хентая ставим флаг censored
    entry.censored = true if data[:entry][:genres].any? {|v| [Genre::HentaiID, Genre::YaoiID].include? v[:id] }
    ## то, что стоит релизом, не сбрасывать назад в онгоинг при ипорте
    #data[:entry].delete(:status) if entry.status == AniMangaStatus::Released &&
                                    #data[:entry][:status] == AniMangaStatus::Ongoing &&
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

    entry = {}

    entry[:name] = parse_h1(content)
    entry[:id] = id
    entry[:description_mal] = parse_synopsis(content)

    parse_block(entry, :related, /<h2>Related Manga?<\/h2>([\s\S]*?)(?:<h2>|<\/td>)/, content)

    entry[:english] = parse_line("English", content, true)
    entry[:japanese] = parse_line("Japanese", content, true)
    entry[:synonyms] = parse_line("Synonyms", content, true)

    alt = entry[:name].permalinked.gsub(/-/, ' ').titleize
    entry[:synonyms] = entry[:synonyms] + [alt] unless entry[:name] == alt || entry[:synonyms].include?(alt)

    entry[:kind] = parse_line("Type", content, false)

    entry[:volumes] = parse_line("Volumes", content, false).to_i
    entry.delete(:volumes) if entry[:volumes] == 0
    entry[:chapters] = parse_line("Chapters", content, false).to_i
    entry.delete(:chapters) if entry[:chapters] == 0

    entry[:status] = parse_line("Status", content, false)
    dates = parse_line("Published", content, false).split(' to ').map do |v|
      parse_date(v)
    end
    entry[:released_on] = dates.size == 2 ? dates[1] : nil
    entry[:aired_on] = dates[0]

    entry[:genres] = parse_line("Genres", content, true).map {|v|
                       v.match(/genre\[\]=(\d+).*>(.*)<\/a>/) ? {id: $1.to_i, name: $2} : nil
                     }.select {|v| v != nil }

    entry[:authors] = parse_line("Authors", content, false).split('),').map {|v|
                       v.match(/people\/(\d+).*>(.*)<\/a> \(([^\)]*)\)?/) ? {id: $1.to_i, name: $2, role: $3} : nil
                     }.select {|v| v != nil }

    publisher = parse_line("Serialization", content, false).
                  match(/mid=(\d+).*>(.*)<\/a>/) ? {id: $1.to_i, name: $2} : nil
    entry[:publishers] = [publisher] if publisher

    #entry[:rating] = parse_line("Rating", content, false)
    entry[:score] = parse_line("Score", content, false).match(/([\d.]+)/) ? $1.to_f : 0
    entry[:score] = 9.99 if entry[:score] >= 10
    entry[:ranked] = parse_line("Ranked", content, false).match(/(\d+)/) ? $1.gsub(",", "").to_i : 0
    entry[:popularity] = parse_line("Popularity", content, false).match(/(\d+)/) ? $1.to_i : 0
    entry[:members] = parse_line("Members", content, false).gsub(",", "").to_i
    entry[:favorites] = parse_line("Favorites", content, false).gsub(",", "").to_i

    doc = Nokogiri::HTML(content)
    img_doc = doc.css("td.borderClass > div > img")

    if img_doc.empty? || img_doc.first.attr(:src) !~ %r{cdn.myanimelist.net}
      entry[:img] = doc.css("td.borderClass > div > a > img").first.attr(:src)
    else
      entry[:img] = img_doc.first.attr(:src)
    end

    raise EmptyContent.new(url) if entry[:english].blank? && entry[:score].blank? && entry[:synonyms].blank? && entry[:name].blank? &&
                                   entry[:status].blank? && entry[:kind].blank? && entry[:ranked].blank?

    entry
  end
end
