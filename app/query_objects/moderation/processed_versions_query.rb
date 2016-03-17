class Moderation::ProcessedVersionsQuery < SimpleQueryBase
  pattr_initialize :type

private

  def query
    Moderation::VersionsItemTypeQuery.new(type).result
      .includes(:user, :moderator)
      .where.not(state: :pending)
      .order(updated_at: :desc)
  end
end
