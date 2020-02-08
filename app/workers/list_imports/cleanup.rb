class ListImports::Cleanup
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  FAIL_INTERVAL = 7.days

  def perform
    ListImport
      .where(state: :pending)
      .where('created_at < ?', FAIL_INTERVAL.ago)
      .update_all state: :failed
  end
end
