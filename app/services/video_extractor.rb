module VideoExtractor
  EXTRACTORS = %i(
    vk youtube coub open_graph smotret_anime sovet_romantica dailymotion
  )

  class << self
    def fetch url
      extractors
        .find { |v| v.valid_url? url }
        &.new(url)
        &.fetch
    end

    def extractors
      @extractors ||= EXTRACTORS.map do |extractor|
        "VideoExtractor::#{extractor.to_s.camelize}Extractor".constantize
      end
    end

    def matcher
      @matcher ||= extractors.map { |klass| klass::URL_REGEX }.join '|'
    end
  end
end
