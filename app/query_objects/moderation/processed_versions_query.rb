class Moderation::ProcessedVersionsQuery < QueryObjectBase

private

  def query
    Version
      .includes(:user, :moderator)
      .where.not(state: :pending)
      .order(updated_at: :desc)
  end
end
