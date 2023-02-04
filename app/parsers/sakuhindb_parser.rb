class SakuhindbParser
  attr_accessor :fail_on_unmatched

  def initialize
    config = YAML::load_file Rails.root.join 'config/app/sakuhindb_parser.yml'

    @ignores = Set.new config[:ignores]
    @matches = config[:matches]
    @deleted = config[:deleted]
  end

  def fetch_and_merge
    data = extract
    data = filter data
    data = fill_ids data
    assert_unmatched data

    merge data
  end

private

  # мерж в базу данных
  def merge data
    data.map do |entry|
      Video.create(
        name: entry[:title],
        anime_id: entry[:anime_id],
        kind: entry[:kind],
        url: "http://www.youtube.com/watch?v=#{entry[:youtube]}",
        uploader_id: BotsService.posters.sample
      )
    end
  end

  # подготовка данных к обработке
  def extract
    fetch_raw_lines.map do |line|
      lines = line.split("\t")
      anime = decode(lines[1], false)
      title = decode(lines[3], true)

      raise "Can't parse line: #{lines.to_json}" if anime.nil?

      {
        anime: anime,
        kind: normalize_kind(lines[2]),
        title: title != lines[4] ? title : nil,
        youtube: lines[4]
      }
    end
  end

  # фильтрация записей от ненужных нам
  def filter data
    data.select do |v|
      v[:kind] != 'ost' &&
        !@ignores.include?(v[:anime]) &&
        !present_videos.include?(v[:youtube]) &&
        !@deleted.include?(v[:youtube])
    end
  end

  # заполнение id для аниме
  def fill_ids data
    data.each do |entry|
      fixed_name = @matches.include?(entry[:anime]) ? @matches[entry[:anime]] : entry[:anime]

      if @matches[entry[:anime]] && @matches[entry[:anime]].kind_of?(Integer)
        entry[:anime_id] = @matches[entry[:anime]]
      else
        names = [fixed_name, entry[:anime2]].compact
        matches = NameMatches::FindMatches.call names, Anime, {}
        entry[:anime_id] = matches.first.id if matches.size == 1
      end
    end
  end

  # финальная проверка с падением при наличии незаматченных данных
  def assert_unmatched data
    unmatched = data.select { |v| v[:anime_id].nil? }.map { |v| v[:anime] }.uniq
    if @fail_on_unmatched && unmatched.any?
      raise MismatchedEntries.new unmatched, [], []
    end
  end

  # исходные данные с источника
  def fetch_raw_lines
    content1 = open("https://en.music.sakuhindb.com/e/created_time/anime.html").read
    doc1 = Nokogiri::HTML content1

    content2 = open("https://en.music.sakuhindb.com/e/created_time/anime_movie.html").read
    doc2 = Nokogiri::HTML content2

    doc1.css('select[name=vid] option').map {|v| v.attr 'value' } +
      doc2.css('select[name=vid] option').map {|v| v.attr 'value' }
  end


  # альтернативное название с источника
  def alt_name name
    content = open("https://en.sakuhindb.com/anime/search.asp?todo=&key=#{Addressable::URI.encode_component name}&lang=e").read
    File.open('/tmp/test.html', 'w') {|v| v.write content }
    doc = Nokogiri::HTML content
    link = doc.css('.va_top td a').first
    link ? link.text : nil
  end

  def utf_hack str
    str.unpack('C*').pack('U*').encode('utf-8', 'utf-8', undef: :replace, invalid: :replace, replace: '')
  end

  def present_videos
    @present_videos ||= Set.new Video.youtube.map do |video|
      video.url =~ VideoExtractor::YoutubeExtractor::URL_REGEX && $~[:key]
    end
  end

  def decode str, with_ignore
    if str =~ /^\d_/
      if str =~ /^7_/ && (!with_ignore || (with_ignore && str !~ /(_\w{2}){3}/))
        str = utf_hack str.sub(/^7_/, '').gsub('_', '%')
        if str.starts_with? '%A5'
          nil
        else
          HTMLEntities.new.decode utf_hack(URI::decode(str))
        end
      else
        nil
      end
    else
      str
    end
  end

  def normalize_kind kind
    case kind
      when 'opening' then 'op'
      when 'ending' then 'ed'
      when 'other_music' then 'ost'
      when 'movie' then 'pv'
      else raise "unknown kind: #{kind}"
    end
  end
end
