class VideoExtractor::MyviExtractor < VideoExtractor::OpenGraphExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>myvi).top/id\w+\?v=[\wА-я_-]+#{PARAMS_REGEXP.source}
    )
  }xi

  def url
    @fixed_url ||= "https:#{Url.new(super).add_www.without_protocol}"
  end
end
