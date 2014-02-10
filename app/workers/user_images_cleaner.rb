class UserImagesCleaner
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    UserImage
      .where(linked_id: nil, linked_type: AnimeNews.name)
      .where('created_at <= ?', 1.week.ago)
      .destroy_all
  end
end
