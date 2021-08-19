class VideoExtractor::VkExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://vk.com/video(-?\d+)_(\d+)#{PARAMS}
  }xi

  API_URL = 'https://api.vk.com/method/video.get'
  API_VERSION = '5.131'

  TOO_MANY_REQUESTS_EROOR_CODE = 6

  def normalize_url url
    super(url).gsub('//vkontakte.ru', '//vk.com')
  end

private

  def extract_image_url data
    url = data[:photo_800] || data[:photo_320]
    return unless url

    Url
      .new(url)
      .without_protocol
      .to_s
  end

  def extract_player_url data
    url = data[:player]
    return unless url

    Url
      .new(url)
      .without_protocol
      .to_s
      .gsub(/&__ref=[^&]+/, '')
      .gsub(/&api_hash=[^&]+/, '')
  end

  def parse_data json, _url
    json&.dig(:response, :items, 0) || {}
  end

  def fetch_page url
    @attempts ||= 1

    json =
      RedisMutex.with_lock('vk_request', block: 1) do
        JSON.parse super(url), symbolize_names: true
      end

    raise RetryError if json&.dig(:error, :error_code) == TOO_MANY_REQUESTS_EROOR_CODE

    json
  rescue RedisMutex::LockError, RetryError
    @attempts += 1
    return if @attempts >= 10

    sleep 1
    retry
  end

  def video_api_url url
    matches = url.match(URL_REGEX)

    API_URL +
      "?videos=#{matches[1]}_#{matches[2]}" \
      "&access_token=#{access_token}" \
      "&v=#{API_VERSION}"
  end

  def access_token
    Rails.application.secrets.vkontakte[:user_access_token]
  end
end
