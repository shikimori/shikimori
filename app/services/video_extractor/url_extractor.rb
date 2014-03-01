class VideoExtractor::UrlExtractor
  def initialize content
    @content = content
  end

  def extract
    if parsed_url
      parsed_url
        .sub(%r{^//}, 'http://')
        .gsub('&amp;', '&')

    else
      data = VideoExtractor.fetch url
      data.player_url if data
    end
  end

private

  def url
    @url ||= @content.to_s.strip
  end

  def html
    @hmtl ||= if url =~ %r{^https?://[^ <>"]+$}
      "src=\"#{url}\""
    else
      url
    end
  end

  def parsed_url
    if html =~ %r{src="((?:https?:)?//(?:vk.com|vkontakte.ru)/video_ext[^"]+)"}
      $1.sub /&hd=\d/, '&hd=3'
    elsif html =~ %r{(?:src|value)="((?:https?:)?//myvi.ru/(?:ru/flash/)?player[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//myvi.tv/embed/html/[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//api.video.mail.ru/videos[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//img.mail.ru/r/video2/player_v2.swf\?[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="movieSrc=([^"]+)"}
      "http://api.video.mail.ru/videos/embed/#{$1.sub /&autoplay=\d/, ''}.html"
    elsif html =~ %r{(?:src|value)="((?:https?:)?//rutube.ru/(?:video|embed)[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//video.rutube.ru/[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//video.sibnet.ru/shell[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//v.kiwi.\w+/(?:v|v2)/[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//p.kiwi.\w+/static/player2/player.swf\?config=[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//(?:www.)?youtube.com/(?:embed|v)/[^"]+)"}
      $1.sub /^\/\//, 'http://'
    elsif html =~ %r{(?:src|value)="((?:https?:)?//i.i.ua/video/evp.swf\?[^"]+)"}
      $1
    elsif html =~ %r{(?:src|value)="((?:https?:)?//video.yandex.ru[^"]+)"}
      $1

    elsif html =~ %r{(?:https?:)?//animeonline.su/player/videofiles}
      puts 'animeonline.su skipped' unless Rails.env.test?
      nil

    elsif html =~ %r{(?:https?:)?//clipiki.ru/flash}
      puts 'clipiki.ru skipped' unless Rails.env.test?
      nil

    elsif html =~ %r{\bi.ua/video/}
      puts 'i.ua skipped' unless Rails.env.test?
      nil

    elsif html =~ %r{(?:https?:)?//(?:vk.com|vkontakte)/video\?q}
      puts 'vk direct link skipped' unless Rails.env.test?
      nil

    else
      puts "can't extract video url: '#{html}'" unless Rails.env.test?
      nil
    end
  end
end
