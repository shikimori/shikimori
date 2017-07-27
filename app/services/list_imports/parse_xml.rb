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

  ANIME_TYPE = 1
  MANGA_TYPE = 2

  def call
    list = data[entry_key]

    (list.is_a?(Hash) ? [list] : list)
      .compact
      .map { |entry| parse entry }
  end

private

  def parse entry
    parse_fields(entry).merge(
      anime_list? ? parse_episodes(entry) : parse_chapters(entry)
    )
  end

  def entry_key
    anime_list? ? 'anime' : 'manga'
  end

  def anime_list?
    data['myinfo']['user_export_type'].to_s == ANIME_TYPE.to_s
  end

  def data
    @data ||= Hash.from_xml(xml)['myanimelist']
  end

  def parse_fields entry
    {
      target_id: parse_id(entry),
      target_type: anime_list? ? Anime.name : Manga.name,
      target_title: entry['series_title'],
      score: extract_number(entry['my_score']),
      status: extract_status(entry['shiki_status'] || entry['my_status']),
      text: entry['my_comments'],
      rewatches: extract_number(entry['my_times_watched'])
    }
  end

  def parse_id entry
    (
      entry["series_#{entry_key}db_id"] ||
        entry["#{entry_key}_#{entry_key}db_id"]
    ).to_i
  end

  def parse_episodes entry
    {
      episodes: extract_number(entry['my_watched_episodes'])
    }
  end

  def parse_chapters entry
    {
      volumes: extract_number(entry['my_read_volumes']),
      chapters: extract_number(entry['my_read_chapters'])
    }
  end

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
