class CommentViewsCleaner
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :cpu_intensive
  )

  def perform
    CommentView.where('comment_id < ?', last_id(Comment)).delete_all
    EntryView.where('entry_id < ?', last_id(Entry)).delete_all
  end

  def last_id klass
    klass .order(created_at: :desc) .where('created_at < ?', (1.week + 1.day).ago) .first
  end
end
