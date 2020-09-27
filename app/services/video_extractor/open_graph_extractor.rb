# no embed videos urls here. video page must contain html so extractor could
# could extract video data from og meta tags
class VideoExtractor::OpenGraphExtractor < VideoExtractor::BaseExtractor
  # Video.hosting should include these hostings
  # shiki_video should include these hostings too

  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>coub).com/view/[\wА-я_-]+#{PARAMS} |
      video.(?<hosting>sibnet).ru/(video[\wА-я_-]+|shell.php\?videoid=[\wА-я_-]+)#{PARAMS}
    )
  }mix
  # (?<hosting>streamable).com/[\wА-я_-]+#{PARAMS} |
  # video.(?<hosting>youmite).ru/embed/[\wА-я_-]+#{PARAMS} |
  # (?<hosting>viuly).io/video/[\wА-я_.-]+#{PARAMS} |
  # (?<hosting>mediafile).online/video/[\wА-я_-]+/[\wА-я_-]+/

  # freeze on attept to make request from shiki
  # (?<hosting>stormo).(?:xyz|tv)/videos/[\wА-я_-]+/[\wА-я_-]+/ 

  # myvi is banned in RF
  # (?:\w+\.)?(?<hosting>myvi).ru/watch/[\wА-я_-]+#{PARAMS} |

  # twitch no long supports og video tags
  # (?:\w+\.)?(?<hosting>twitch).tv(/[\wА-я_-]+/[\wА-я_-]+|/videos)/
    # [\wА-я_-]+#{PARAMS} |

  IMAGE_PROPERTIES = %w[
    meta[property='og:image']
  ]

  VIDEO_PROPERTIES_BY_HOSTING = {
    # viuly: %w[meta[property='og:video:iframe']],
    stormo: %w[meta[property='og:video']]
  }

  VIDEO_PROPERTIES = %w[
    meta[name='twitter:player']
    meta[property='og:video:iframe']
    meta[property='og:video']
    meta[property='og:video:url']
  ]

  def image_url
    Url.new(parsed_data.first).without_protocol.to_s if parsed_data.first
  end

  def player_url
    return unless parsed_data.second

    Url.new(parsed_data.second).without_protocol.to_s
  end

  def hosting
    url.match(self.class::URL_REGEX) && $LAST_MATCH_INFO[:hosting].to_sym
  end

  def parse_data html
    doc = Nokogiri::HTML html

    og_image = doc.css(IMAGE_PROPERTIES.join(',')).first
    og_video = (self.class::VIDEO_PROPERTIES_BY_HOSTING[hosting] || self.class::VIDEO_PROPERTIES)
      .map { |v| doc.css(v).first }
      .find(&:present?)

    if og_image && og_video
      [
        og_image[:content],
        og_video[:content] || og_video[:value]
      ]
    end
  end
end
