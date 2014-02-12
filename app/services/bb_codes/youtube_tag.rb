class BbCodes::YoutubeTag
  include Singleton

  def format text
    preprocess(text).gsub /(?<text>[^"\]=]|^)(?<url>#{VideoExtractor::YoutubeExtractor::URL_REGEX})/mi do
      $~[:text] + to_html($~[:url])
    end
  end

  def preprocess text
    text.gsub /\[url=(?<url>https?:\/\/(?:www\.)?youtube.com\/watch\?(?:feature=player_embedded&(?:amp;)?)?v=([^&\s<>#]+?)([^\s<>]+?)?)\].*?\[\/url\]/mi do
      "#{$~[:url]} "
    end
  end

private
  def to_html url
    video = Video.new url: url
    @template ||= Slim::Template.new Rails.root.join('app', 'views', 'videos', '_video.html.slim').to_s
    @template.render OpenStruct.new(video: video)
  end
end
