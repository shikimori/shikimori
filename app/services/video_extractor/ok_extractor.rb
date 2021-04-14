class VideoExtractor::OkExtractor < VideoExtractor::OpenGraphExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?
    (?<hosting>ok).ru/(videoembed|live|video)/(?<key>[\wА-я_-]+)#{PARAMS}
  }mix

  def normalize_url url
    super.gsub %r{/(?:videoembed|live)/}, '/video/'
  end
end
