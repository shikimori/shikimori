class VideoExtractor::DailymotionExtractor < VideoExtractor::OpenGraphExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>dailymotion).com/(?:embed/)?video/[\wА-я_%-]+#{PARAMS_REGEXP.source}
    )
  }xi

  def url
    super.gsub '/embed', ''
  end
end
