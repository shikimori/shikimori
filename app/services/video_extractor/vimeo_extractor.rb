class VideoExtractor::VimeoExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>vimeo).com/(?<id>[\wА-я_-]+)#{PARAMS}
    )
  }xi

  def video_api_url
    'https://api.vimeo.com/videos/' + video_id
  end

  def video_id
    @video_id ||= url.match(self.class::URL_REGEX)[:id]
  end

  def image_url
    parsed_data.first
  end

  def player_url
    "//player.vimeo.com/video/#{parsed_data.second}"
  end

  def parse_data json
    data = JSON.parse(json, symbolize_names: true)
    image = data.dig(:pictures, :sizes, 3, :link)

    [image, video_id] if image
  end

  def fetch_page
    OpenURI.open_uri(video_api_url, { 'Authorization' => "Bearer #{access_token}" }).read
  end

  def access_token
    Rails.application.secrets.vimeo[:app_access_token]
  end
end
