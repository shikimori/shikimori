class BbCodes::VkTag
  include Singleton

  def format text
    text.gsub /(?<text>[^"\]=]|^)(?<url>#{VideoExtractor::VkExtractor::URL_REGEX})/mi do
      $~[:text] + to_html($~[:url])
    end
  end

private
  def to_html url
    video = Video.new url: url

    if video.vk?
      @template ||= Slim::Template.new Rails.root.join('app', 'views', 'videos', '_video.html.slim').to_s
      @template.render OpenStruct.new(video: video)
    else
      url
    end
  end
end
