class VideoExtractor::CoubExtractor < VideoExtractor::OpenGraphExtractor
  # Video.hosting should include these hostings
  # shiki_video should include these hostings too
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>coub).com/view/[\wА-я_-]+#{PARAMS}
    )
  }xi

private

  def normalize_url url
    "https:#{Url.new(super).without_protocol}"
  end

  def extract_player_url data
    url = super
    Url.new(super).params(autostart: true, startWithHD: true).to_s if url
  end
end
