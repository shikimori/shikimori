class VersionsQuery < QueryObjectBase
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
      .where(state: :accepted)
      .except(:order)
      .order(created_at: :asc)
      .map(&:user)
      .uniq
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
end
