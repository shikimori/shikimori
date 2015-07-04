# TODO: refactor
class AnimeMalParser < BaseMalParser
  STATUSES = {
    'Not yet aired' => 'anons',
    'Currently Airing' => 'ongoing',
    'Finished Airing' => 'released'
  }
  RATINGS = {
    'None' => 'none',
    'G - All Ages' => 'g',
    'PG - Children' => 'pg',
    'PG-13 - Teens 13 or older' => 'pg_13',
    'R - 17+ (violence & profanity)' => 'r',
    'R+ - Mild Nudity' => 'r_plus',
    'Rx - Hentai' => 'rx'
  }

  # сохранение уже импортированных данных
  def deploy entry, data
    # для хентая ставим флаг censored
    if data[:entry][:genres].any? {|v| v[:id] == Genre::HentaiID || v[:id] == Genre::YaoiID || v[:id] == Genre::YuriID }
      entry.censored = true
    end
    # то, что стоит релизом, не сбрасывать назад в онгоинг при ипорте
    data[:entry].delete(:status) if entry.released? &&
                                    data[:entry][:status] == 'ongoing' &&
                                    entry.episodes_aired == entry.episodes
    # студии
    super
  end

  # загрузка информации по манге
  def fetch_entry_data id
    content = get entry_url(id)

    entry = {}
    entry[:name] = parse_h1(content)
    entry[:id] = id
    entry[:description_mal] = parse_synopsis(content)

    parse_block(entry, :related, /Related Anime<\/h2>([\s\S]*?)(?:<h2>|<\/td>)/, content)
    #unless entry[:related].nil?
      #entry[:related_mangas] = entry[:related].select {|k,v| k == RelatedAdaptationName }
      #entry[:related_animes] = entry[:related].select {|k,v| k != RelatedAdaptationName }
    #end

    entry[:english] = parse_line("English", content, true)
    entry[:synonyms] = parse_line("Synonyms", content, true)
    entry[:japanese] = parse_line("Japanese", content, true)

    alt = entry[:name].permalinked.gsub(/-/, ' ').titleize
    entry[:synonyms] = entry[:synonyms] + [alt] unless entry[:name] == alt || entry[:synonyms].include?(alt)

    entry[:kind] = parse_line("Type", content, false).downcase.gsub(/ |-/, '_')

    entry[:episodes] = parse_line("Episodes", content, false).to_i
    entry.delete(:episodes) if entry[:episodes] == 0

    entry[:status] = STATUSES[parse_line("Status", content, false)]
    dates = parse_line("Aired", content, false).split(' to ').map do |v|
      parse_date(v)
    end
    entry[:released_on] = dates.size == 2 ? dates[1] : nil
    entry[:aired_on] = dates[0]

    entry[:genres] = parse_line("Genres", content, true).map {|v|
                        v.match(/genre\[\]=(\d+).*>(.*)<\/a>/) ? {id: $1.to_i, name: $2} : nil
                      }.select {|v| v != nil }
    entry[:studios] = parse_line("Producers", content, true).map {|v|
                        v.match(/p=(\d+).*>(.*)<\/a>/) ? {id: $1.to_i, name: $2} : nil
                      }.select {|v| v != nil }
    entry[:duration] = parse_line("Duration", content, false)
    entry[:duration] = (entry[:duration].match(/(\d+) hr./) ? $1.to_i*60 : 0) +
                        (entry[:duration].match(/(\d+) min./) ? $1.to_i : 0)
    entry[:rating] = RATINGS[parse_line("Rating", content, false)]
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

    raise EmptyContent.new(url) if entry[:english].blank? && entry[:synonyms].blank? && entry[:status].blank? && entry[:kind].blank? && entry[:rating].blank?
    entry
  end
end
