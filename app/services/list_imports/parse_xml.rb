class ListImports::ParseXml
  method_object :xml

  STATUSES = {
    'plan to watch' => 'planned',
    'plan to read' => 'planned',
    'watching' => 'watching',
    'reading' => 'watching',
    'completed' => 'completed',
    'on-hold' => 'on_hold',
    'on hold' => 'on_hold', # "On Hold" is in Kitsu lists
    'dropped' => 'dropped',
    'rewatching' => 'rewatching',
    'rereading' => 'rewatching'
  }

  ANIME_TYPE = 1
  MANGA_TYPE = 2

  def call
    list = data[entry_key]
    list_data = (list.is_a?(Hash) ? [list] : list).compact

    list_data.map do |list_entry_data|
      build(parse(list_entry_data))
    end
  end

private

  def build list_entry_data
    ListImports::ListEntry.new list_entry_data
  end

  def parse list_entry_data
    {
      target_id: parse_id(list_entry_data),
      target_type: anime_list? ? Anime.name : Manga.name,
      target_title: list_entry_data['series_title'],
      score: extract_number(list_entry_data['my_score']),
      status: extract_status(
        list_entry_data['shiki_status'] || list_entry_data['my_status']
      ),
      text: list_entry_data['my_comments'],
      rewatches: extract_number(list_entry_data['my_times_watched']),
      episodes: extract_number(list_entry_data['my_watched_episodes']),
      volumes: extract_number(list_entry_data['my_read_volumes']),
      chapters: extract_number(list_entry_data['my_read_chapters'])
    }
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

  def parse_id list_entry_data
    (
      list_entry_data["series_#{entry_key}db_id"] ||
        list_entry_data["#{entry_key}_#{entry_key}db_id"]
    ).to_i
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
