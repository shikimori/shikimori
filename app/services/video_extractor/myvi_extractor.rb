class VideoExtractor::MyviExtractor < VideoExtractor::OpenGraphExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>myvi).(?:top|tv)/id\w+\?v=[\wА-я_-]+#{PARAMS}
    )
  }xi

  def url
    @fixed_url ||= 'https:' +
      Url.new(
        super.gsub('//myvi.tv', '//myvi.top')
      ).add_www.without_protocol.to_s
  end

  def image_url
    UrlGenerator.instance.camo_url(super)
  end
end
