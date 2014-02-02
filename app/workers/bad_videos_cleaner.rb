class BadVideosCleaner
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    videos.each do |video|
      unless video.valid?
        video.suggest_deletion BotsService.get_poster
      end
    end
  end

private
  def videos
    Video
      .where(state: 'confirmed')
      .order(id: :desc)
      .uniq(&:url)
  end
end
