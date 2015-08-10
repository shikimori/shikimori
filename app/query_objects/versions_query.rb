class VersionsQuery
  pattr_initialize :entry

  def all
    entry_versions(@entry)
      .decorate
  end

  def by_field field
    entry_versions(@entry)
      .where("(item_diff->>:field) is not null", field: field)
      .decorate
  end

  def [] field
    @versions ||= {}
    @versions[field.to_s] ||= by_field field
  end

private

  def entry_versions entry
    Version
      .where(item: @entry)
      .where.not(state: :deleted)
      .includes(:user, :moderator)
      .order(created_at: :desc)
  end
end
