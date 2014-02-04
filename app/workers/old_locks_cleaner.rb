class OldLocksCleaner
  include Sidekiq::Worker

  def perform
    UserChange
      .where(status: UserChangeStatus::Locked)
      .where('created_at <= ?', DateTime.now - 1.month)
      .destroy_all
  end
end

