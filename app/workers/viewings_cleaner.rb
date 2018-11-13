class ViewingsCleaner
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform
    CommentViewing.where('viewed_id < ?', last_id(Comment)).delete_all
    TopicViewing.where('viewed_id < ?', last_id(Topic)).delete_all
  end

  def last_id klass
    klass
      .order(created_at: :desc)
      .where('created_at < ?', (1.week + 1.day).ago)
      .first
  end
end
