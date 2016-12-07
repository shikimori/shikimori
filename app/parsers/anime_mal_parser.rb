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
    entry.censored = data[:entry][:rating] == 'rx' ||
      data[:entry][:genres].any? { |v| Genre::CENSORED_IDS.include? v[:mal_id] }
    # то, что стоит релизом, не сбрасывать назад в онгоинг при ипорте
    data[:entry].delete(:status) if entry.released? &&
                                    data[:entry][:status] == 'ongoing' &&
                                    entry.episodes_aired == entry.episodes
    # студии
    super
  end

  def fetch_model id
    content = get entry_url(id)
    raise EmptyContent.new(url) if content.include? "404 Not Found"
    doc = Nokogiri::HTML(content)

    entry = {}
    entry[:name] = parse_h1(content)
    entry[:id] = id
    entry[:description_en] = processed_description_en(id, content)

    #parse_block(entry, :related, /Related Anime<\/h2>([\s\S]*?)(?:<h2>|<\/td>)/, content)
    entry[:related] = parse_related doc

    entry[:english] = parse_line("English", content, true).first
    entry[:synonyms] = parse_line("Synonyms", content, true)
    entry[:japanese] = parse_line("Japanese", content, true).first

    alt = entry[:name].permalinked.gsub(/-/, ' ').titleize
    entry[:synonyms] = entry[:synonyms] + [alt] unless entry[:name] == alt || entry[:synonyms].include?(alt)

    entry[:kind] = parse_line("Type", content, false)
      .downcase
      .gsub(/ |-/, '_')
      .sub('unknown', '')
      .gsub(/<.*?>/, '')

    entry[:episodes] = parse_line("Episodes", content, false).to_i
    entry.delete(:episodes) if entry[:episodes] == 0

    entry[:status] = STATUSES[parse_line("Status", content, false)]
    entry[:origin] = parse_line("Source", content, false).downcase.tr(' ', '_').tr('-', '_')
    dates = parse_line("Aired", content, false).split(' to ').map do |v|
      parse_date(v)
    end
    entry[:released_on] = dates.size == 2 ? dates[1] : nil
    entry[:aired_on] = dates[0]

    entry[:genres] = parse_line("Genres", content, true)
      .map do |line|
        {
          mal_id: $1.to_i,
          name: $2,
          kind: 'anime',
        } if line =~ /genre\/(\d+).*>(.*)<\/a>/
      end
      .select(&:present?)

    entry[:studios] = parse_line("Studios", content, true)
      .map do |line|
        {
          id: $1.to_i,
          name: $2
        } if line =~ /producer\/(\d+).*>(.*)<\/a>/
      end
      .select(&:present?)

    duration = parse_line("Duration", content, false)
    entry[:duration] = (duration.match(/(\d+) hr./) ? $1.to_i*60 : 0) + (duration.match(/(\d+) min./) ? $1.to_i : 0)
    entry[:broadcast] = parse_line("Broadcast", content, false)
    entry[:broadcast] = nil if entry[:broadcast] == 'Unknown' || entry[:broadcast].blank?

    entry[:rating] = RATINGS[CGI::unescapeHTML(parse_line 'Rating', content, false)]
    entry[:score] = parse_score(content)
    entry[:ranked] = parse_ranked(content)
    entry[:popularity] = parse_line("Popularity", content, false).match(/(\d+)/) ? $1.to_i : 0
    entry[:members] = parse_line("Members", content, false).gsub(",", "").to_i
    entry[:favorites] = parse_line("Favorites", content, false).gsub(",", "").to_i

    doc = Nokogiri::HTML(content)

    entry[:img] = parse_poster doc
    entry[:external_links] = parse_external_links doc

    # left_column_doc = doc.css("td.borderClass").first()

    # img_doc = left_column_doc.css('> div > img')
    # img_doc = left_column_doc.css('> div > div > a > img') if img_doc.empty? || img_doc.first.attr(:src) !~ %r{cdn.myanimelist.net}
    # img_doc = left_column_doc.css('> div > a > img') if img_doc.empty? || img_doc.first.attr(:src) !~ %r{cdn.myanimelist.net}

    # entry[:img] = img_doc.first&.attr('data-src') || img_doc.first&.attr(:src)

    raise EmptyContent.new(url) if entry[:english].blank? && entry[:synonyms].blank? && entry[:status].blank? && entry[:kind].blank? && entry[:rating].blank?
    entry
  end
end
