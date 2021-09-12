class UserImages::CleanupJob
  include Sidekiq::Worker
  sidekiq_options queue: :cleanup_jobs

  def perform user_image_id
    UserImage.find_by(id: user_image_id)&.destroy
  end
end
