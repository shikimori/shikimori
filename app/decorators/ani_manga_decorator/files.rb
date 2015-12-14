class AniMangaDecorator::Files
  pattr_initialize :entry

  def search_phrases
    @search_phrases ||= ([
      entry.torrents_name,
      entry.name,
      entry.name.sub(/\d+$/, ''),
      entry.name.sub(/:.*/, ''),
      entry.name.sub(/:.*/, '').sub(/\d+$/, ''),
      entry.name.sub(/\(.*\)/, '')
    ] + (entry.english || []) + (entry.synonyms || []))
        .compact
        .uniq
        .map {|v| v.gsub(/[():]/, '').sub(/\/div>[\s\S]*/, '').strip }
        .uniq
  end

  def rutracker_search
    ([
      (entry.aired_on && entry.russian.present? ? "#{entry.russian} #{(entry.aired_on+1.month).year}" : nil),
      (entry.aired_on ? "#{entry.name} #{(entry.aired_on+1.month).year}" : nil),
      (entry.aired_on && entry.torrents_name.present? ? "#{entry.torrents_name} #{(entry.aired_on+1.month).year}" : nil),
      entry.russian,
      (entry.russian || '').sub(/:.*/, ''),
      (entry.russian || '').sub(/\(.*\)/, ''),
    ] + search_phrases).select(&:present?).uniq
  end

  def toshokan_search
    (search_phrases + (entry.japanese || [])).compact.uniq
  end

  def subtitles
    @subtitles ||= entry.subtitles.sort_by {|k,v| v[:link] == nil ? 2 : 1 }.select {|k,subs| subs[:title] }
  end

  def groupped_torrents
    @groupped_torrents ||= begin
      torrents_480p = entry.torrents_720p.empty? ? entry.torrents_480p.sort_by {|v| v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years }.uniq {|v| v[:title] }.reverse : []
      torrents_720p = entry.torrents_720p.sort_by {|v| v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years }.uniq {|v| v[:title] }.reverse
      torrents_1080p = entry.torrents_1080p.sort_by {|v| v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years }.uniq {|v| v[:title] }.reverse
      torrents = (entry.torrents - torrents_480p - torrents_720p - torrents_1080p).select {|v| v.kind_of?(Hash) }.sort_by do |v|
        v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years
      end.uniq {|v| v[:title] }.reverse
      if entry.released? && (entry.released_on || entry.aired_on) && DateTime.now.to_i - (entry.released_on || entry.aired_on).to_time.to_i > 60*60*24*364
        torrents_480p = []
        torrents_720p = []
        torrents_1080p = []
      end

      groupped_torrents = {}
      groupped_torrents[:torrents_480p] = torrents_480p if torrents_480p.any?
      groupped_torrents[:torrents_720p] = torrents_720p if torrents_720p.any?
      groupped_torrents[:torrents_1080p] = torrents_1080p if torrents_1080p.any?
      groupped_torrents[:torrents] = torrents if torrents.any?

      groupped_torrents
    end
  end

  def episodes_data
    torrents = significant_torrents
    topics = entry.news.limit AnimeDecorator::NewsPerPage

    data = topics.each_with_object({}) do |entry, memo|
      memo[entry.id] = torrents
          .select {|v| TorrentsParser.extract_episodes_num(v[:title]).include? entry.value.to_i }
          .map do |v|
            {
              title: v[:title],
              link: v[:link]
            }
          end
    end
  end

private

  def significant_torrents
    (groupped_torrents[:torrents_1080p] || []) +
        (groupped_torrents[:torrents_720p] || []) +
        (groupped_torrents[:torrents_480p] || [])
  end
end
