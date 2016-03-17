class VersionsQuery < SimpleQueryBase
  pattr_initialize :entry
  decorate_page true

  def all
    query.decorate
  end

  def by_field field
    query
      .where("(item_diff->>:field) is not null", field: field)
      .decorate
  end

  def authors field
    query
      .where("(item_diff->>:field) is not null", field: field)
      .where(state_condition field)
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
      .where(item: entry)
      .where.not(state: :deleted)
      .includes(:user, :moderator)
      .order(created_at: :desc)
  end

  def state_condition field
    if field.to_sym == :screenshots || field.to_sym == :videos
      "(item_diff->>'action') in (
        #{Version.sanitize Versions::ScreenshotsVersion::ACTIONS[:upload]},
        #{Version.sanitize Versions::VideoVersion::ACTIONS[:upload]}
      )"
    end
  end
end
