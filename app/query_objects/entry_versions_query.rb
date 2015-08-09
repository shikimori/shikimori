class EntryVersionsQuery
  pattr_initialize :entry

  # TODO: вставить проверку изменяемого поля
  def by_field field
    Version
      .where(item: @entry)
      .where("(item_diff->>:field) is not null", field: field)
      .where.not(state: :deleted)
      .includes(:user, :moderator)
      .order(created_at: :desc)
      .decorate
  end

  def [] field
    @versions ||= {}
    @versions[field.to_s] ||= by_field field
  end
end
