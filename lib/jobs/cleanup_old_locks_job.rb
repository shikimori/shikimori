class CleanupOldLocksJob
  def perform
    UserChange.where(status: UserChangeStatus::Locked)
        .where { created_at.lte my{DateTime.now - 1.month} }
        .destroy_all
  end
end

