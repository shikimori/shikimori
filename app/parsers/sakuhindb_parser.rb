class SakuhindbParser
  attr_accessor :fail_on_unmatched

  CONFIG_PATH = Rails.root.join 'config/app/sakuhindb_parser.yml'

  def initialize
    config = YAML.load_file CONFIG_PATH

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

  def merge data
    data
      .select { |v| v[:anime_id].present? }
      .map do |entry|
        uploader = User.find BotsService.posters.sample

        Versioneers::VideosVersioneer
          .new(Anime.find(entry[:anime_id]))
          .upload(
            {
              name: entry[:title],
              kind: entry[:kind],
              url: "http://www.youtube.com/watch?v=#{entry[:youtube]}",
              uploader_id: uploader.id
            },
            uploader
          )
      end
  end

  def extract
    fetch_raw_lines.map do |line|
      lines = line.split("\t")
      anime = decode(lines[1], false)
      title = decode(lines[3], true)

      raise "Can't parse line: #{lines.to_json}" if anime.nil?

      {
        anime: anime,
        kind: normalize_kind(lines[2]),
        title: title == lines[4] ? nil : title,
        youtube: lines[4]
      }
    end
  end

  def filter data
    data.select do |v|
      v[:kind] != 'ost' &&
        @ignores.exclude?(v[:anime]) &&
        present_videos.exclude?(v[:youtube]) &&
        @deleted.exclude?(v[:youtube])
    end
  end

  def fill_ids data
    data.each do |entry|
      fixed_name = @matches.include?(entry[:anime]) ? @matches[entry[:anime]] : entry[:anime]

      if @matches[entry[:anime]] && @matches[entry[:anime]].is_a?(Integer)
        entry[:anime_id] = @matches[entry[:anime]]
      else
        names = [fixed_name, entry[:anime2]].compact
        matches = NameMatches::FindMatches.call names, Anime, {}
        entry[:anime_id] = matches.first.id if matches.size == 1
      end
    end
  end

  def assert_unmatched data
    unmatched = data.select { |v| v[:anime_id].nil? }.map { |v| v[:anime] }.uniq
    if @fail_on_unmatched && unmatched.any?
      raise MismatchedEntries.new unmatched, [], []
    end
  end

  def fetch_raw_lines
    content1 = open('https://en.music.sakuhindb.com/e/created_time/anime.html').read
    doc1 = Nokogiri::HTML content1

    content2 = open('https://en.music.sakuhindb.com/e/created_time/anime_movie.html').read
    doc2 = Nokogiri::HTML content2

    doc1.css('select[name=vid] option').map { |v| v.attr 'value' } +
      doc2.css('select[name=vid] option').map { |v| v.attr 'value' }
  end

  def alt_name name
    content = open("https://en.sakuhindb.com/anime/search.asp?todo=&key=#{Addressable::URI.encode_component name}&lang=e").read
    File.write('/tmp/test.html', content)
    doc = Nokogiri::HTML content
    link = doc.css('.va_top td a').first
    link ? link.text : nil
  end

  def utf_hack str
    str.unpack('C*').pack('U*').encode('utf-8', 'utf-8', undef: :replace, invalid: :replace,
      replace: '')
  end

  def present_videos
    @present_videos ||= Set.new Video.youtube.map do |video|
      video.url =~ VideoExtractor::YoutubeExtractor::URL_REGEX && $~[:key]
    end
  end

  def decode str, with_ignore
    if /^\d_/.match?(str)
      if str =~ /^7_/ && (!with_ignore || (with_ignore && str !~ /(_\w{2}){3}/))
        str = utf_hack str.sub(/^7_/, '').tr('_', '%')
        if str.starts_with? '%A5'
          nil
        else
          HTMLEntities.new.decode utf_hack(URI.decode(str))
        end
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
