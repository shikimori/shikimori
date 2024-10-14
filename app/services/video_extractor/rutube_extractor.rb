class VideoExtractor::RutubeExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    (?:https?:)? // (?:www\.)?
    rutube\.ru/(?:video|shorts)/(?<key>[\w_-]+)
    (?:
      /?
      (?:
        [?&]
        (?:
          [\w_-]+(?:=[\w_-]+)?
        )
      )*
    )?
  }ix

  API_URL_TEMPLATE = 'https://rutube.ru/api/video/%<key>s/thumbnail/'
  PLAYER_URL_TEMPLATE = 'https://rutube.ru/play/embed/%<key>s'

private

  def extract_hosting url
    url.include?('/shorts/') ?
      Types::Video::Hosting[:rutube_shorts] :
      super
  end

  def video_api_url url
    format API_URL_TEMPLATE, key: extract_key(url)
  end

  def parse_data content, url
    key = extract_key(url)

    {
      key:,
      thumbnail_url: JSON.parse(content)['url'] + '?width=300',
      player_url: format(PLAYER_URL_TEMPLATE, key:)
    }
  end

  def extract_key url
    URL_REGEX.match(url)[:key]
  end

  def extract_image_url data
    data[:thumbnail_url]
  end

  def extract_player_url data
    data[:player_url]
  end
end
