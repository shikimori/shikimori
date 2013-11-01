# парсер http://findanime.ru
class FindAnimeParser < ReadMangaParser
  def extract_additional doc
    episodes = doc
      .css('.chapters-link tr a')
      .map {|v| parse_chapter v }
      .select {|v| v[:episode].present? }
      .map {|v| fetch_episode v }


    { episodes: episodes }
  end

  def fetch_episode episode
    content = get episode[:url]

    episode[:videos] = Nokogiri::HTML(content).css('.chapter-link').map do |node|
      description = node.css('.video-info .details').text.strip
      kind, author = $1, $2 if description =~ /(.*)[\s\S]*\((.*)\)/

      episode.reverse_merge({
        kind: extract_kind(kind || description),
        language: extract_language(kind || description),
        source: episode[:url],
        url: extract_url(node.css('.embed_source').first.attr('value'), episode[:url]),
        author: author
      })
    end

    episode
  end

  def extract_kind kind
    case kind
      when 'Озвучка' then :dubbed
      when 'Сабы', 'Английские сабы' then :subbed
      when 'Оригинал' then :raw
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
    if html =~ %r{src="(https?://vk.com/video_ext[^"]+)"}
      $1.sub /&hd=\d/, '&hd=3'
    elsif html =~ %r{src="(https?://myvi.ru/player[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://api.video.mail.ru/videos[^"]+)"}
      $1
    elsif html =~ %r{value="movieSrc=([^"]+)"}
      "http://api.video.mail.ru/videos/embed/#{$1.sub /&autoplay=\d/, ''}.html"
    elsif html =~ %r{src="(https?://rutube.ru/video[^"]+)"}
      $1
    elsif html =~ %r{src="(https?://video.sibnet.ru/shell[^"]+)"}
      $1
    else
      raise "unexpected video source: '#{source}'\n'#{html}'"
    end
  end

  def parse_chapter node
    {
      episode: node.text.match(/Серия (\d+)/) ? node.text.match(/Серия (\d+)/)[1].to_i : nil,
      url: "http://#{@domain}#{node.attr 'href'}?mature=1"
    }
  end
end
