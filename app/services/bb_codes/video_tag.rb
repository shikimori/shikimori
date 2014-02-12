class BbCodes::VideoTag
  include Singleton

  def format text
    times = 0
    preprocess(text).gsub /(?<text>[^"\]=]|^)(?<url>#{VideoExtractor.matcher})/mi do
      is_youtube = $~[:url].include? 'youtube.com/'
      times += 1 unless is_youtube

      if times <= 10 || is_youtube
        $~[:text] + to_html($~[:url])
      else
        $~[:text] + $~[:url]
      end
    end
  end

  def preprocess text
    text.gsub /\[url=(?<url>#{VideoExtractor.matcher})\].*?\[\/url\]/mi do
      "#{$~[:url]} "
    end
  end

private
  def to_html url
    video = Video.new url: url

    if video.hosting.present?
      @template = Slim::Template.new Rails.root.join('app', 'views', 'videos', '_video.html.slim').to_s
      @template.render OpenStruct.new(video: video)
    else
      url
    end
  end
end
