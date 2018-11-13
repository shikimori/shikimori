class UserImagesCleaner
  include Sidekiq::Worker

  def perform
    UserImage
      .where(linked_id: nil, linked_type: Topics::NewsTopic.name)
      .where('created_at <= ?', 1.week.ago)
      .destroy_all
  end
end
