class VersionsQuery < SimpleQueryBase
  pattr_initialize :item
  decorate_page true

  def all
    query.decorate
  end

  def by_field field
    query
      .where('(item_diff->>:field) is not null', field: field)
      .decorate
  end

  def authors field
    query
      .where('(item_diff->>:field) is not null', field: field)
      .where(state_condition(field))
      .where(state: :accepted)
      .except(:order)
      .order(created_at: :asc)
      .map(&:user)
      .uniq { |user| user.bot? ? 'bot' : user }
  end

  def [] field
    @versions ||= {}
    @versions[field.to_s] ||= by_field field
  end

private

  def query
    Version
      .where(item: @item)
      .or(Version.where(associated: @item))
      .where.not(state: :deleted)
      .includes(:user, :moderator)
      .order(created_at: :desc)
  end

  def state_condition field
    return unless field.to_sym == :screenshots || field.to_sym == :videos

    screenshots_sql = ApplicationRecord.sanitize(
      Versions::ScreenshotsVersion::Actions[:upload]
    )

    videos_sql = ApplicationRecord.sanitize(
      Versions::VideoVersion::Actions[:upload]
    )

    "(item_diff->>'action') in (#{screenshots_sql}, #{videos_sql})"
  end
end
