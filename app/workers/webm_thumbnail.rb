# ffmpeg надо собрать с поддержкой vp9
#   http://wiki.webmproject.org/ffmpeg/building-with-libvpx
# конфигурить с такими параметрами:
#   ./configure --enable-libvpx --enable-libvorbis --enable-gnutls --enable-network --enable-protocol=http --enable-protocol=https
class WebmThumbnail
  include Sidekiq::Worker

  sidekiq_options queue: :webm_thumbnails

  def perform webm_video_id
    webm_video = WebmVideo.find webm_video_id
    thumbnail_path = "/tmp/webm_thumbnail_#{webm_video.id}.jpg"

    grab_thumbnail webm_video.url, thumbnail_path

    if File.exist? thumbnail_path
      webm_video.update thumbnail: open(thumbnail_path)
      webm_video.process!
    else
      webm_video.to_failed!
    end
  end

private

  def grab_thumbnail url, path
    `ffmpeg -y -i #{url} -ss 00:00:05 -vframes 1 #{path}`
  end
end
