# парсер http://findanime.ru
class FindAnimeParser < ReadMangaParser
  def initialize
    super
    #@proxy_log = true
  end

  def fetch_entry id
    OpenStruct.new super
  end

  def extract_additional entry, doc
    video_links = doc.css('.chapters-link tr a')
    videos = video_links
      .map {|v| parse_chapter v, video_links.count }
      .select {|v| v[:episode].present? }

    if videos.empty? && doc.css('.chapter-link').to_html =~ /Озвучка|Сабы/
      videos = [{episode: 1, url: "http://#{@domain}#{doc.css('h3 a').first.attr('href').sub /#.*/, ''}"}]
    end

    names = doc.css('div[title="Так же известно под названием"]').text.split('/ ').map(&:strip)

    entry[:episodes] = doc.css('.subject-meta').text[/Серий:\s*(\d+)/, 1].try(&:to_i) || 0
    entry[:year] = doc.css('.elem_year').map(&:text).map(&:strip).map(&:to_i).first
    entry[:categories] = doc.css('.elem_category').map(&:text).map(&:strip)
    entry[:videos] = videos
    entry[:names] = entry[:names] + names
  end

  def fetch_videos episode, url
    Nokogiri::HTML(get(url)).css('.chapter-link').map do |node|
      description = node.css('.video-info .details').text.strip

      kind, author = $1, $2 if description =~ /(.*)[\s\S]*\((.*)\)/
      kind = extract_kind kind || description
      author ||= node.css('.video-info').to_html[/<span class="additional">.*?<\/span>(?:<\/span>)?([\s\S]*)<span/, 1].try :strip

      embed_source = node.css('.embed_source').first

      OpenStruct.new(
        episode: episode,
        kind: kind,
        language: extract_language(kind || description),
        source: url,
        url: extract_url(embed_source.attr('value'), url),
        author: HTMLEntities.new.decode(author)
      ) if embed_source && kind
    end.compact
  end

  def extract_kind kind
    case kind
      when 'Озвучка', 'Озвучка+сабы', 'Многоголосый' then :fandub
      when 'Сабы', 'Английские сабы', 'Хардсаб', 'Хардсаб+сабы' then :subtitles
      when 'Оригинал' then :raw
      when '' then :unknown
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

  def extract_url html, source=:unknown
    if html =~ %r{src="((?:https?:)?//(?:vk.com|vkontakte.ru)/video_ext[^"]+)"}
      $1.sub /&hd=\d/, '&hd=3'
    elsif html =~ %r{(?:src|value)="((?:https?:)?//myvi.ru/(?:ru/flash/)?player[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//api.video.mail.ru/videos[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//img.mail.ru/r/video2/player_v2.swf\?[^"]+)"}
      $1
    elsif html =~ %r{value="movieSrc=([^"]+)"}
      "http://api.video.mail.ru/videos/embed/#{$1.sub /&autoplay=\d/, ''}.html"
    elsif html =~ %r{src="((?:https?:)?//rutube.ru/(?:video|embed)[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//video.rutube.ru/[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//video.sibnet.ru/shell[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//v.kiwi.\w+/(?:v|v2)/[^"]+)"}
      $1
    elsif html =~ %r{value="((?:https?:)?//p.kiwi.\w+/static/player2/player.swf\?config=[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//(?:www.)?youtube.com/(?:embed|v)/[^"]+)"}
      $1.sub /^\/\//, 'http://'
    elsif html =~ %r{src="((?:https?:)?//i.i.ua/video/evp.swf\?[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//video.yandex.ru[^"]+)"}
      $1

    elsif html =~ %r{(?:https?:)?//animeonline.su/player/videofiles}
      puts 'animeonline.su skipped' unless Rails.env.test?
      nil

    elsif html =~ %r{(?:https?:)?//clipiki.ru/flash}
      puts 'clipiki.ru skipped' unless Rails.env.test?
      nil

    elsif html =~ %r{(?:https?:)?//(?:vk.com|vkontakte)/video\?q}
      puts 'vk direct link skipped' unless Rails.env.test?
      nil

    else
      #raise "unexpected video source: '#{source}'\n'#{html}'"
      puts "unexpected video source: '#{source}'\n'#{html}'"
      nil
    end
  end

  def parse_chapter node, total_episodes=1
    {
      episode: node.text.match(/Серия (\d+)/) ?
                 node.text.match(/Серия (\d+)/)[1].to_i :
                 (node.text.match(/Фильм полностью/) ?
                   (total_episodes > 5 ? 0 : 1) :
                   nil),
      url: "http://#{@domain}#{node.attr 'href'}?mature=1"
    }
  end

  def load_cache
    @cache = {entries: {}}
  end

  def save_cache
  end
end
