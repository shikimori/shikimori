class VideoExtractor::SovetRomanticaExtractor < VideoExtractor::BaseExtractor
  URL_REGEX = VideoExtractor::PlayerUrlExtractor::SOVET_ROMANTICA_REGEXP

  def initialize url
    super
    return unless valid_url?

    @url = Url.new(VideoExtractor::PlayerUrlExtractor.call(@url)).with_protocol.to_s
  end

  def image_url
    return unless parsed_data[:image_url]

    Url.new(parsed_data[:image_url]).without_protocol.to_s
  end

  def player_url
    Url.new(@url).without_protocol.to_s
  end

  def parse_data html
    doc = Nokogiri::HTML html

    {
      image_url: doc.css('video').first.attr('poster')
    }
  end
end
