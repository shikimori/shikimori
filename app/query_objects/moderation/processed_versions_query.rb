class Moderation::ProcessedVersionsQuery < SimpleQueryBase
  pattr_initialize :type, :created_on

private

  def query
    scope = Moderation::VersionsItemTypeQuery.new(type).result
      .includes(:user, :moderator)
      .where.not(state: :pending)
      .order(updated_at: :desc)

    if created_on
      scope = scope.where(
        "created_at between ? and ?",
        Time.zone.parse(created_on).beginning_of_day,
        Time.zone.parse(created_on).end_of_day,
      )
    end

    scope
  end
end
