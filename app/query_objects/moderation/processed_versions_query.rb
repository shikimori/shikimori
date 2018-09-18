class Moderation::ProcessedVersionsQuery < SimpleQueryBase
  pattr_initialize :type, :created_on

  def query
    scope = Moderation::VersionsItemTypeQuery.call(type)
      .includes(:user, :moderator)
      .where.not(state: :pending)
      .order(updated_at: :desc)

    if created_on
      scope.where!(
        'created_at between ? and ?',
        Time.zone.parse(created_on).beginning_of_day,
        Time.zone.parse(created_on).end_of_day
      )
    end

    scope
  end
end
