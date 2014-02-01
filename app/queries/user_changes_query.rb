class UserChangesQuery
  def initialize(entry, field)
    @entry = entry
    @field = field.to_s
  end

  def fetch
    UserChange.where(item_id: @entry.id, model: @entry.class.name.downcase, column: @field)
      .where(status: [UserChangeStatus::Pending, UserChangeStatus::Taken, UserChangeStatus::Accepted])
      .includes(:user)
      .includes(:approver)
      .order(created_at: :desc)
  end

  def authors(with_taken = true)
    if with_taken
      fetch.where(status: [UserChangeStatus::Taken, UserChangeStatus::Accepted])
    else
      fetch.where(status: UserChangeStatus::Accepted)
    end.select('distinct(user_id)').map(&:user)
  end

  def lock
    UserChange.where(model: @entry.class.name, item_id: @entry.id, status: UserChangeStatus::Locked)
        .includes(:user)
        .first
  end
end
