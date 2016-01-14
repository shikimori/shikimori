class UserImagesCleaner
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  def perform
    UserImage
      .where(linked_id: nil, linked_type: Topics::NewsTopic.name)
      .where('created_at <= ?', 1.week.ago)
      .destroy_all
  end
end
