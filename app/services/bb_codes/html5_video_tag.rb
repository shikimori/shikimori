class BbCodes::Html5VideoTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = %r{
    \[html5_video\]
      (?<url> .*?)
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

    if webm_video.thumbnail.exists?
      html_with_image webm_video
    else
      html_without_image webm_video
    end
  end

  def html_with_image webm_video
    <<-HTML.squish
      <div class="b-video fixed">
        <img class="to-process" data-dynamic="html5_video" \
          src="#{webm_video.thumbnail.url :normal}" \
          srcset="#{webm_video.thumbnail.url :retina} 2x" \
          data-video="#{webm_video.url}" \
        />
        <a class="marker" href="#{webm_video.url}">html5</a>
      </div>
    HTML
  end

  def html_without_image webm_video
    <<-HTML.squish
      <div class="b-video fixed">
        <img class="to-process" data-dynamic="html5_video" \
          src="#{DEFAULT_THUMBNAIL_NORMAL}" \
          srcset="#{DEFAULT_THUMBNAIL_RETINA} 2x" \
          data-src="#{webm_video.thumbnail.url :normal}" \
          data-srcset="#{webm_video.thumbnail.url :retina} 2x" \
          data-video="#{webm_video.url}" \
        />
        <a class="marker" href="#{webm_video.url}">html5</a>
      </div>
    HTML
  end
end
