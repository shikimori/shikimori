module VideoExtractor
  @extractors = [:vk, :youtube].map do |extractor|
    "VideoExtractor::#{extractor.capitalize}Extractor".constantize
  end

  def self.fetch url
    extractor = @extractors.find do |extractor|
      extractor.valid_url? url
    end

    extractor.new(url).fetch if extractor
  end
end
