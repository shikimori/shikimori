class BbCodes::Tags::VideoUrlTag
  include Singleton

  MAXIMUM_VIDEOS = 75
  PREPROCESS_REGEXP = %r{
    \[url=(?<url> #{VideoExtractor.matcher} )\]
      .*?
    \[/url\]
  }mix
  VIDEO_REGEXP = /
    # (?<! \[url\] )
    (?: \[url\] )?
    (?<url> #{VideoExtractor.matcher} )
  /mix

  def format text
    times = 0

    preprocess(text).gsub VIDEO_REGEXP do |match|
      next match if match.starts_with? '[url]'

      is_youtube = $LAST_MATCH_INFO[:url].include? 'youtube.com/'
      times += 1 unless is_youtube

      if times <= MAXIMUM_VIDEOS || is_youtube
        to_html($LAST_MATCH_INFO[:url])
      else
        $LAST_MATCH_INFO[:url]
      end
    end
  end

  def preprocess text
    text.gsub PREPROCESS_REGEXP do
      "#{$LAST_MATCH_INFO[:url]} "
    end
  end

private

  def to_html url
    video = Video.new url: url
    return url if video.hosting.blank?

    Slim::Template
      .new(Rails.root.join('app/views/videos/_video.html.slim'))
      .render(OpenStruct.new(video: video))
  end
end
