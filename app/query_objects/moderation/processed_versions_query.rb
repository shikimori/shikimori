class Moderation::ProcessedVersionsQuery
  def self.fetch type, created_on
    scope = Moderation::VersionsItemTypeQuery.fetch(type)
      .includes(:user, :moderator)
      .where('state != ?', :pending)
      .order(updated_at: :desc)

    if created_on
      scope = scope.where(
        'created_at between ? and ?',
        Time.zone.parse(created_on).beginning_of_day,
        Time.zone.parse(created_on).end_of_day
      )
    end

    scope
  end
end
