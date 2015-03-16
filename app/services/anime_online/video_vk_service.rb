module AnimeOnline
  class VideoVkService
    pattr_initialize :video

    def cut_hd!
      return unless video.vk?
      return unless video.url.include?('&hd=3')
      video.update!(url: video.url.gsub(/&hd=3$/, ''))
    end
  end
end
