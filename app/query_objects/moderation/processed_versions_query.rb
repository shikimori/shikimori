class Moderation::ProcessedVersionsQuery < SimpleQueryBase
  pattr_initialize :type, :created_on

private

  def query
    scope = Moderation::VersionsItemTypeQuery.new(type).result
      .includes(:user, :moderator)
      .where.not(state: :pending)
      .order(updated_at: :desc)

    if created_on
      scope = scope.where("cast(created_at as date) = ?", created_on.to_date)
    end

    scope
  end
end
