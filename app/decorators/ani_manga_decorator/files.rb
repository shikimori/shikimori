# TODO: refactor everything
class AniMangaDecorator::Files
  pattr_initialize :entry

  def search_phrases
    @search_phrases ||= ([
      entry.torrents_name,
      entry.name,
      entry.name.sub(/\d+$/, ''),
      entry.name.sub(/:.*/, ''),
      entry.name.sub(/:.*/, '').sub(/\d+$/, ''),
      entry.name.sub(/\(.*\)/, ''),
      entry.english
    ] + (entry.synonyms || []))
        .select(&:present?)
        .uniq
        .map {|v| v.gsub(/[():]/, '').sub(/\/div>[\s\S]*/, '').strip }
        .uniq
  end

  def rutracker_search
    ([
      (entry.aired_on.present? && entry.russian.present? ? "#{entry.russian} #{(entry.aired_on.date + 1.month).year}" : nil),
      (entry.aired_on.present? ? "#{entry.name} #{(entry.aired_on.date + 1.month).year}" : nil),
      (entry.aired_on.present? && entry.torrents_name.present? ? "#{entry.torrents_name} #{(entry.aired_on.date + 1.month).year}" : nil),
      entry.russian,
      (entry.russian || '').sub(/:.*/, ''),
      (entry.russian || '').sub(/\(.*\)/, ''),
    ] + search_phrases).select(&:present?).uniq
  end

  def toshokan_search
    (search_phrases + [entry.japanese]).select(&:present?).uniq
  end

  def subtitles
    @subtitles ||= Animes::Subtitles::Get.call(entry)
      .sort_by { |_k, value| value[:link] ? 2 : 1 }
      .select { |_k, value| value[:title] }
  end

  def grouped_torrents
    @grouped_torrents ||= begin
      sorted_torrents_480p = torrents_720p.empty? ? torrents_480p.sort_by {|v| v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years }.uniq {|v| v[:title] }.reverse : []
      sorted_torrents_720p = torrents_720p.sort_by {|v| v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years }.uniq {|v| v[:title] }.reverse
      sorted_torrents_1080p = torrents_1080p.sort_by {|v| v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years }.uniq {|v| v[:title] }.reverse

      sorted_torrents = (torrents - torrents_480p - torrents_720p - torrents_1080p).select {|v| v.kind_of?(Hash) }.sort_by do |v|
        v[:pubDate] && [DateTime, Time].include?(v[:pubDate].class) ? v[:pubDate] : DateTime.now - 40.years
      end.uniq { |v| v[:title] }.reverse
      # if entry.released? && (entry.released_on || entry.aired_on) && DateTime.now.to_i - (entry.released_on || entry.aired_on).to_time.to_i > 60*60*24*364
      #   torrents_480p = []
      #   torrents_720p = []
      #   torrents_1080p = []
      # end

      grouped_torrents = {}
      grouped_torrents[:torrents_480p] = sorted_torrents_480p if sorted_torrents_480p.any?
      grouped_torrents[:torrents_720p] = sorted_torrents_720p if sorted_torrents_720p.any?
      grouped_torrents[:torrents_1080p] = sorted_torrents_1080p if sorted_torrents_1080p.any?
      grouped_torrents[:torrents] = sorted_torrents if sorted_torrents.any?

      grouped_torrents
    end
  end

  def episodes_data
    torrents = significant_torrents
    topics = entry
      .news_topics
      .limit AnimeDecorator::MAX_NEWS

    topics.each_with_object({}) do |entry, memo|
      memo[entry.id] = torrents
        .select do |v|
          TorrentsParser.extract_episodes_num(v[:title]).include?(
            entry.value.to_i
          )
        end
        .map do |v|
          { title: v[:title], link: v[:link] }
        end
    end
  end

private

  def significant_torrents
    (grouped_torrents[:torrents_1080p] || []) +
      (grouped_torrents[:torrents_720p] || []) +
      (grouped_torrents[:torrents_480p] || [])
  end

  def torrents
    @torrents ||= Animes::Torrents::Get.call(entry)
  end

  def torrents_480p
    @torrents_480p ||= torrents
      .select do |v|
        v.is_a?(Hash) && v[:title] && v[:title].match(/x480|480p/)
      end
      .reverse
  end

  def torrents_720p
    @torrents_720p ||= torrents
      .select do |v|
        v.is_a?(Hash) && v[:title] && v[:title].match(/x720|x768|720p/)
      end
      .reverse
  end

  def torrents_1080p
    @torrents_1080p ||= torrents
      .select do |v|
        v.is_a?(Hash) && v[:title] && v[:title].match(/x1080|1080p/)
      end
      .reverse
  end
end
