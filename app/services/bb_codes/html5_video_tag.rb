class BbCodes::Html5VideoTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = /
    \[html5_video\]
      (?<url> .*?)
    \[\/html5_video\]
  /mix

  DEFAULT_THUMBNAIL_NORMAL = '/assets/globals/html5_video.png'
  DEFAULT_THUMBNAIL_RETINA = '/assets/globals/html5_video@2x.png'

  def format text
    text.gsub REGEXP do
      url = $~[:url]
      html_tag(url).strip
    end
  end

private

  def html_tag url
    webm_video = WebmVideo.find_or_create_by url: url

    <<-end
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
    end
  end
end
