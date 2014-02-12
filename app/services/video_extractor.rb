module VideoExtractor
  class << self
    def fetch url
      extractor = extractors.find do |extractor|
        extractor.valid_url? url
      end

      extractor.new(url).fetch if extractor
    end

    def extractors
      @extractors ||= [:vk, :youtube].map do |extractor|
        "VideoExtractor::#{extractor.capitalize}Extractor".constantize
      end
    end

    def matcher
      @matcher ||= extractors.map {|klass| klass::URL_REGEX }.join '|'
    end
  end
end
