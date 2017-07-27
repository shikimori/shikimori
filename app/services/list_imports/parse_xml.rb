class ListImports::ParseXml
  method_object :xml

  STATUSES = {
    'plan to watch' => 'planned',
    'plan to read' => 'planned',
    'watching' => 'watching',
    'reading' => 'watching',
    'completed' => 'completed',
    'on-hold' => 'on_hold',
    'dropped' => 'dropped',
    'rewatching' => 'rewatching',
    'rereading' => 'rewatching'
  }

  def call
    list = data[entry_key]

    (list.is_a?(Hash) ? [list] : list)
      .compact
      .map { |entry| parse entry }
  end

private

  def parse entry
    if anime_list?
      parse_anime entry
    else
      parse_manga entry
    end
  end

  def entry_key
    anime_list? ? 'anime' : 'manga'
  end

  def anime_list?
    data['myinfo']['user_export_type'].to_s ==
      UserRatesImporter::ANIME_TYPE.to_s
  end

  def data
    @data ||= Hash.from_xml(xml)['myanimelist']
  end

  def parse_anime entry
    {
      target_id: (entry['series_animedb_id'] || entry['anime_animedb_id']).to_i,
      target_type: Anime.name,
      episodes: extract_number(entry['my_watched_episodes']),
      rewatches: extract_number(entry['my_times_watched']),
      status: extract_status(entry['shiki_status'] || entry['my_status']),
      score: extract_number(entry['my_score']),
      text: entry['my_comments']
    }
  end

  # rubocop:disable AbcSize
  def parse_manga entry
    {
      target_id: (entry['series_mangadb_id'] || entry['manga_mangadb_id']).to_i,
      target_type: Manga.name,
      volumes: extract_number(entry['my_read_volumes']),
      chapters: extract_number(entry['my_read_chapters']),
      rewatches: extract_number(entry['my_times_watched']),
      status: extract_status(entry['shiki_status'] || entry['my_status']),
      score: extract_number(entry['my_score']),
      text: entry['my_comments']
    }
  end
  # rubocop:enable AbcSize

  def extract_number data
    (data || 0).to_i
  end

  def extract_status status
    if status.match?(/^\d+$/)
      number_to_status status.to_i
    else
      string_to_status status
    end
  end

  def number_to_status status
    if [5, 6].include? status
      0
    else
      status
    end
  end

  def string_to_status status
    STATUSES[status.downcase]
  end
end
