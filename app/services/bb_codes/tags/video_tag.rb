class BbCodes::Tags::VideoTag
  include Singleton

  URL_SYMBOL_CLASS = /[^"'<>\[\]]/.source
  REGEXP = %r{
    \[video=(?<id>\d+)\]
      |
    \[video\] (?<url> #{URL_SYMBOL_CLASS}*? ) \[/video\]
  }x

  MAXIMUM_VIDEOS = 75

  def format text
    times = 0

    text.gsub REGEXP do |matched|
      if $LAST_MATCH_INFO[:id]
        video_id_html($LAST_MATCH_INFO[:id]) || matched
      else
        url = $LAST_MATCH_INFO[:url]
        times += 1 unless url.match? VideoExtractor::YoutubeExtractor::URL_REGEX

        times < MAXIMUM_VIDEOS ? video_url_html(url) : url
      end
    end
  end

private

  def video_id_html id
    video = Video.find_by id: id
    html_for video if video
  end

  def video_url_html url
    video = Video.new url: url
    return url if video.hosting.blank?

    html_for video
  end

  def html_for video
    Slim::Template
      .new(Rails.root.join('app/views/videos/_video.html.slim'))
      .render(OpenStruct.new(video: video))
  end
end
