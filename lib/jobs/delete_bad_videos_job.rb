class DeleteBadVideosJob
  def perform
    Video.where(state: 'confirmed').order('id desc').uniq_by(&:url).each do |video|
      unless video.valid?
        video.suggest_deletion BotsService.get_poster
      end
    end
  end
end
