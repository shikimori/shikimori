class VideoExtractor::VimeoExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>vimeo).com/(?<id>[\wА-я_-]+)#{PARAMS}
    )
  }xi

private

  def video_id url
    url.match(self.class::URL_REGEX)[:id]
  end

  def video_api_url url
    'https://api.vimeo.com/videos/' + video_id(url)
  end

  def extract_image_url data
    data.first
  end

  def extract_player_url data
    "//player.vimeo.com/video/#{data.second}"
  end

  def parse_data json, url
    data = JSON.parse(json, symbolize_names: true)
    image = data.dig(:pictures, :sizes, 3, :link)

    [image, video_id(url)] if image
  end

  def open_uri_options
    super.merge('Authorization' => "Bearer #{access_token}")
  end

  def access_token
    Rails.application.secrets.vimeo[:app_access_token]
  end
end
