class BbCodes::Tags::Html5VideoTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = %r{
    \[html5_video\]
      (?<url> .*? )
    \[/html5_video\]
  }mix

  DEFAULT_THUMBNAIL_NORMAL = '/assets/globals/html5_video.png'
  DEFAULT_THUMBNAIL_RETINA = '/assets/globals/html5_video@2x.png'
  RETRY_OPTIONS = {
    tries: 2,
    on: [ActiveRecord::RecordNotUnique],
    sleep: 1
  }

  def format text
    text.gsub REGEXP do
      url = $LAST_MATCH_INFO[:url]
      html_tag(url).strip
    end
  end

private

  def html_tag url
    webm_video = Retryable.retryable(RETRY_OPTIONS) do
      WebmVideo.find_or_create_by url: url
    end

    <<-HTML.squish
      <div class="b-video fixed">
        <div class="video-link">
          <img class="to-process" data-dynamic="html5_video" \
            src="#{DEFAULT_THUMBNAIL_NORMAL}" \
            srcset="#{DEFAULT_THUMBNAIL_RETINA} 2x" \
            data-src="#{webm_video.thumbnail.url :normal}" \
            data-srcset="#{webm_video.thumbnail.url :retina} 2x" \
            data-video="#{ERB::Util.h webm_video.url}" \
          />
        </div>
        <a class="marker" href="#{ERB::Util.h webm_video.url}">html5</a>
      </div>
    HTML
  end
end
