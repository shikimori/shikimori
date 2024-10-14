class VideoExtractor::YoutubeExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    (?:https?:)? // (?:www\.)?
    (?:
      youtube\.com/
      \S*? (?: &(?:amp;)? | \? )
      v=(?<key>[\w_-]+)
      [^\ $#<\[\]\r\n]*
      (?:\#(?:t|at)=(?<time>\d+))?

      |

      youtu.be/
      (?<key>[\w_-]+)
      (?:
        [?&]
        (?:
          (?:t|at)=(?<time>\w+) |
          [\w_-]+(?:=[\w_-]+)?
        )
      )*

      |

      youtube\.com/(?:embed|v)/
      (?<key>[\w_-]+)
      (?:\?start=(?<time>\w+))?

      |

      youtube.com/(?<shorts>shorts)/
      (?<key>[\w_-]+)
      (?:
        [?&]
        [\w_-]+(?:=[\w_-]+)?
      )*
    )
  }xi

private

  def remote_request_required?
    false
  end

  def extract_hosting url
    url.include?('/shorts/') ?
      Types::Video::Hosting[:youtube_shorts] :
      super
  end

  def extract_image_url match
    "//img.youtube.com/vi/#{match[:key]}/#{match[:shorts] ? :oardefault : :hqdefault}.jpg"
  end

  def extract_player_url match
    "//youtube.com/embed/#{match[:key]}" +
      (match[:time].present? ? "?start=#{match[:time]}" : '')
  end

  # def exists?
  #   # задержка, т.к. ютуб блочит при частых запросах
  #   sleep 1 unless Rails.env.test?
  #
  #   open("http://i.ytimg.com/vi/#{matches[:key]}/hqdefault.jpg").read.present?
  # rescue *Network::FaradayGet::NET_ERRORS
  #   false
  # end

  def normalize_matched_url url, match
    url.include?('/shorts/') ?
      "https://www.youtube.com/shorts/#{match[:key]}" :
      "https://youtu.be/#{match[:key]}"
  end
end
