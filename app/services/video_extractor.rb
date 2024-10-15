# how to add new video hosting:
# 1. add extractor of video data (image_url, player_url, hosting) similar to
#   VideoExtractor::OpenGraphExtractor or VideoExtractor::VkExtractor
# 2. add hosting into Video if you want video urls to be parsed on forums
#   after that add test into BbCodes::Tags::VideoUrlTag spec
# 3. add new video hosting into shiki_video.js
# 4. add new video hosting into shiki_editor link_url_paste_rule.js
module VideoExtractor
  EXTRACTORS = %i[
    vk ok youtube rutube coub vimeo open_graph
  ]

  class << self
    def fetch url
      extractors.each do |extractor|
        entry = extractor.instance.fetch url
        return entry if entry
      end

      nil
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
