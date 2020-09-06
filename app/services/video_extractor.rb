# how to add new video hosting:
# 1. add extractor of video data (image_url, player_url, hosting) similar to
#   VideoExtractor::OpenGraphExtractor or VideoExtractor::VkExtractor
# 2. add embed player url parsing in VideoExtractor::PlayerUrlExtractor
# 3. add hosting into Video if you want video urls to be parsed on forums
#   after that add test into BbCodes::Tags::VideoUrlTag spec
# 4. add new video hosting into shiki_video.js
module VideoExtractor
  EXTRACTORS = %i[
    vk ok youtube coub vimeo open_graph rutube
    smotret_anime sovet_romantica myvi
  ] # dailymotion

  class << self
    def fetch url
      extractors.find { |v| v.valid_url? url }&.new(url)&.fetch
    end

    def extractors
      @extractors ||= EXTRACTORS.map do |extractor|
        "VideoExtractor::#{extractor.to_s.camelize}Extractor".constantize
      end
    end

    def matcher
      @matcher ||= extractors
        .map { |klass| "(?:#{klass::URL_REGEX.source})" }
        .join('|')
    end
  end
end
