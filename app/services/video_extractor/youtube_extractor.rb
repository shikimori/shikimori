class VideoExtractor::YoutubeExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = %r{
    https?://(?:www\.)?youtube\.com/
    .*?(?:&|\?)
    v=(?<key>[^ &#$]+)
    [^ $#]*
    (?:\#t=(?<time>\d+))?
  }xi

  def image_url
    "http://img.youtube.com/vi/#{matches[:key]}/mqdefault.jpg"
  end

  def player_url
    "http://youtube.com/v/#{matches[:key]}" + (matches[:time].present? ? "?start=#{matches[:time]}" : '')
  end

  def matches
    @matches ||= url.match URL_REGEX
  end
end
