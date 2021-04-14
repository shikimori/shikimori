class VideoExtractor::YoutubeExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    (?:https?:)? // (?:www\.)?
    (?:
      youtube\.com/
      .*? (?: &(?:amp;)? | \? )
      v=(?<key>[\w_-]+)
      [^\ $#<\[\]\r\n]*
      (?:\#(?:t|at)=(?<time>\d+))?

      |

      youtu.be/
      (?<key>[\w_-]+)
      (?:\?(?:t|at)=(?<time>\w+))?

      |

      youtube\.com/(?:embed|v)/
      (?<key>[\w_-]+)
      (?:\?start=(?<time>\w+))?
    )
  }xi

private

  def image_url
    "//img.youtube.com/vi/#{matches[:key]}/hqdefault.jpg"
  end

  def player_url
    "//youtube.com/embed/#{matches[:key]}" +
      (matches[:time].present? ? "?start=#{matches[:time]}" : '')
  end

  def matches
    @matches ||= url.match URL_REGEX
  end

  # def parsed_data
  #   Videos::ExtractedEntry.new(
  #   )
  # end

  # def exists?
  #   # задержка, т.к. ютуб блочит при частых запросах
  #   sleep 1 unless Rails.env.test?
  #
  #   open("http://i.ytimg.com/vi/#{matches[:key]}/hqdefault.jpg").read.present?
  # rescue *Network::FaradayGet::NET_ERRORS
  #   false
  # end
end
