class VideoExtractor::MyviExtractor < VideoExtractor::OpenGraphExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>myvi).(?:top|tv)/id\w+\?v=[\wА-я_-]+#{PARAMS}
    )
  }xi
  URL_REPLACEMENT = %r{//myvi\.(?:tv|top)}

private

  def normalize_url url
    super.gsub(URL_REPLACEMENT, '//www.myvi.top')
  end

  def extract_image_url url
    UrlGenerator.instance.camo_url(super)
  end
end
