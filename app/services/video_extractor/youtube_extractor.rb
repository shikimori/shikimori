class VideoExtractor::YoutubeExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    (?:https?:)? // (?:www\.)?
    (?:
      youtube\.com/
      .*? (?: &(?:amp;)? | \? )
      v=(?<key>[\w_-]+)
      [^ $#<\[]*
      (?:\#t=(?<time>\d+))?

      |

      youtu.be/
      (?<key>[\w_-]+)
      (?:\?t=(?<time>\w+))?

      |

      youtube\.com/(?:embed|v)/
      (?<key>[\w_-]+)
      (?:\?start=(?<time>\w+))?
    )
  }xi

  def image_url
    "//img.youtube.com/vi/#{matches[:key]}/mqdefault.jpg"
  end

  def player_url
    "//youtube.com/embed/#{matches[:key]}" +
      (matches[:time].present? ? "?start=#{matches[:time]}" : '')
  end

  def matches
    @matches ||= url.match URL_REGEX
  end

  def opengraph_page?
    true
  end

  def exists?
    # задержка, т.к. ютуб блочит при частых запросах
    sleep 1 unless Rails.env.test?

    open("http://i.ytimg.com/vi/#{matches[:key]}/mqdefault.jpg").read.present?
  rescue OpenURI::HTTPError
    false
  end
end
