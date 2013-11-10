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
    episodes = doc
      .css('.chapters-link tr a')
      .map {|v| parse_chapter v }
      .select {|v| v[:episode].present? }

    names = doc.css('div[title="Так же известно под названием"]').text.split('/ ').map(&:strip)

    entry[:episodes] = episodes
    entry[:names] = entry[:names] + names
  end

  def fetch_videos episode, url
    Nokogiri::HTML(get(url)).css('.chapter-link').map do |node|
      description = node.css('.video-info .details').text.strip

      kind, author = $1, $2 if description =~ /(.*)[\s\S]*\((.*)\)/
      kind = extract_kind kind || description
      author ||= node.css('.video-info').to_html[/<span class="additional">.*?<\/span>([\s\S]*)<span/, 1].try :strip

      embed_source = node.css('.embed_source').first

      OpenStruct.new({
        episode: episode,
        kind: kind,
        language: extract_language(kind || description),
        source: url,
        url: extract_url(embed_source.attr('value'), url),
        author: HTMLEntities.new.decode(author)
      }) if embed_source && kind
    end.compact
  end

  def extract_kind kind
    case kind
      when 'Озвучка', 'Озвучка+сабы' then :fandub
      when 'Сабы', 'Английские сабы' then :subtitles
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

  def extract_url html, source
    if html =~ %r{src="(https?://(?:vk.com|vkontakte.ru)/video_ext[^"]+)"}
      $1.sub /&hd=\d/, '&hd=3'
    elsif html =~ %r{(?:src|value)="(https?://myvi.ru/(?:ru/flash/)?player[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://api.video.mail.ru/videos[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://img.mail.ru/r/video2/player_v2.swf\?[^"]+)"}
      $1
    elsif html =~ %r{value="movieSrc=([^"]+)"}
      "http://api.video.mail.ru/videos/embed/#{$1.sub /&autoplay=\d/, ''}.html"
    elsif html =~ %r{src="(https?://rutube.ru/(?:video|embed)[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://video.rutube.ru/[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://video.sibnet.ru/shell[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://v.kiwi.\w+/(?:v|v2)/[^"]+)"}
      $1
    elsif html =~ %r{value="(https?://p.kiwi.\w+/static/player2/player.swf\?config=[^"]+)"}
      $1
    elsif html =~ %r{src="((?:https?:)?//(?:www.)?youtube.com/(?:embed|v)/[^"]+)"}
      $1.sub /^\/\//, 'http://'
    elsif html =~ %r{src="(https?://i.i.ua/video/evp.swf\?[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://video.yandex.ru[^"]+)"}
      $1

    elsif html =~ %r{http://animeonline.su/player/videofiles}
      puts 'animeonline.su skipped' unless Rails.env.test?
      nil

    elsif html =~ %r{http://clipiki.ru/flash}
      puts 'clipiki.ru skipped' unless Rails.env.test?
      nil

    elsif html =~ %r{https?://(?:vk.com|vkontakte)/video\?q}
      puts 'vk direct link skipped' unless Rails.env.test?
      nil

    else
      #raise "unexpected video source: '#{source}'\n'#{html}'"
      puts "unexpected video source: '#{source}'\n'#{html}'"
      nil
    end
  end

  def parse_chapter node
    {
      episode: node.text.match(/Серия (\d+)/) ? node.text.match(/Серия (\d+)/)[1].to_i : nil,
      url: "http://#{@domain}#{node.attr 'href'}?mature=1"
    }
  end
end
