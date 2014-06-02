class UserListParsers::XmlListParser
  def initialize klass
    @klass = klass
  end

  def parse xml
    extract_list(xml)
      .map {|v| @klass == Anime ? parse_anime(v) : parse_manga(v) }
      .compact
  end

private
  def extract_list xml
    list = Hash.from_xml(xml.fix_encoding)['myanimelist'][@klass.name.downcase]
    list.kind_of?(Hash) ? [list] : list
  end

  def parse_anime entry
    {
      id: (entry['series_animedb_id'] || entry['anime_animedb_id']).to_i,
      episodes: (entry['my_watched_episodes'] || 0).to_i,
      rewatches: (entry['my_times_watched'] || 0).to_i,
      status: extract_status(entry['shiki_status'] || entry['my_status']),
      score: (entry['my_score'] || 0).to_i,
      text: entry['my_comments']
    }
  end

  def parse_manga entry
    {
      id: (entry['series_mangadb_id'] || entry['manga_mangadb_id']).to_i,
      volumes: (entry['my_read_volumes'] || 0).to_i,
      chapters: (entry['my_read_chapters'] || 0).to_i,
      rewatches: (entry['my_times_watched'] || 0).to_i,
      status: extract_status(entry['shiki_status'] || entry['my_status']),
      score: (entry['my_score'] || 0).to_i,
      text: entry['my_comments']
    }
  end

  def extract_status status
    status =~ /^\d+$/ ? number_to_status(status.to_i) : string_to_status(status)
  end

  def number_to_status status
    if status == 5 || status == 6
      0
    else
      status
    end
  end

  def string_to_status status
    case status.downcase
      when 'plan to watch', 'plan to read' then UserRate.status_id(:planned)
      when 'watching', 'reading' then UserRate.status_id(:watching)
      when 'completed' then UserRate.status_id(:completed)
      when 'on-hold' then UserRate.status_id(:on_hold)
      when 'dropped' then UserRate.status_id(:dropped)
      when 'rewatching', 'rereading' then UserRate.status_id(:rewatching)
    end
  end

  def self.status_to_string status, klass, is_mal_status
    if klass == Anime
      case status.to_sym
        when :planned then 'Plan to Watch'
        when :watching then 'Watching'
        when :completed then 'Completed'
        when :on_hold then 'On-Hold'
        when :dropped then 'Dropped'
        when :rewatching then is_mal_status ? 'Completed' : 'Rewatching'
        else raise ArgumentError, status
      end

    else
      case status.to_sym
        when :planned then 'Plan to Read'
        when :watching then 'Reading'
        when :completed then 'Completed'
        when :on_hold then 'On-Hold'
        when :dropped then 'Dropped'
        when :rewatching then is_mal_status ? 'Completed' : 'Rereading'
        else raise ArgumentError, status
      end
    end
  end
end
