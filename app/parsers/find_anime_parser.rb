# парсер http://findanime.ru
class FindAnimeParser < ReadMangaParser
  def initialize
    super
    #@proxy_log = true
  end

  # парсинг информации об аниме по идентификатору
  def fetch_entry id
    OpenStruct.new super
  end

  # парсинг дополнительной информации
  def extract_additional entry, doc
    video_links = doc.css(chapters_selector)
    videos = video_links
      .map {|v| parse_chapter v, video_links.count }
      .select {|v| v[:episode].present? }

    if videos.empty? && doc.css('.chapter-link').to_html =~ /озвучка|сабы/i && doc.css('h3 a').any?
      videos = [{episode: 1, url: "http://#{domain}#{doc.css('h3 a').first.attr('href').sub /#.*/, ''}"}]
    end

    names = doc.css('div[title="Так же известно под названием"]').text.split('/ ').map(&:strip)

    entry[:episodes] = doc.css('.subject-meta').text[/Серий:\s*(\d+)/, 1].try(&:to_i) || 0
    entry[:year] = doc.css('.elem_year').map(&:text).map(&:strip).map(&:to_i).first
    entry[:categories] = doc.css('.elem_category').map(&:text).map(&:strip).map(&:downcase)
    entry[:videos] = videos
    entry[:names] = entry[:names] + names
  end

  # загрузка и парсинг информации по эпизоду видео
  def fetch_videos episode, url
    Nokogiri::HTML(get(url)).css('.chapter').map do |node|
      description = node.css('.video-info .details').text.strip
      if description.blank?
        description = node.css('.video-info').children.last.text.split("\n").map(&:strip).select(&:present?).last
      end

      kind, author = $1, $2 if description =~ /(.*)[\s\S]*\((.*)\)/
      kind = extract_kind kind || description
      author ||= node.css('.video-info').to_html[/<span class="additional">.*?<\/span>(?:<\/span>)?([\s\S]*)<span/, 1].try :strip

      embed_source = node.css('.embed_source').first
      video_url = VideoExtractor::UrlExtractor
        .new(embed_source.attr 'value').extract if embed_source

      ParsedVideo.new(
        episode: episode,
        kind: kind,
        language: extract_language(kind && !kind.kind_of?(Symbol) ? kind : description),
        source: url,
        url: video_url,
        author: HTMLEntities.new.decode(author)
      ) if embed_source && kind && video_url
    end.compact
  end

  def extract_kind kind
    case kind
      when /Озвучка/i, 'Озвучка+сабы', /Многоголосый/i then :fandub
      when /Сабы/i, 'Английские сабы', /Хардсаб/i, 'Хардсаб+сабы' then :subtitles
      when /Оригинал/i then :raw
      when '', nil, /DVD-rip/i, /TV-rip/i, /Full HD/i then :unknown
      else
        raise "unexpected russian kind: '#{kind}'"
    end
  end

  def extract_language kind
    if kind =~ /Английские сабы/
      :english
    else
      :russian
    end
  end

  def parse_chapter node, total_episodes=1
    {
      episode: node.text.match(/Серия (\d+)/) ?
        node.text.match(/Серия (\d+)/)[1].to_i :
        (node.text.match(/Фильм полностью/) ?
          (total_episodes > 5 ? 0 : 1) :
          nil),
      url: "http://#{domain}#{node.attr 'href'}?mature=1"
    }
  end

  def load_cache
    @cache = {entries: {}}
  end

  def save_cache
  end

  def chapters_selector
    '.chapters-link tr a'
  end
end
