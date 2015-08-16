# выборка из базы id элементов с пользовательскими правками
class ChangedItemsQuery
  pattr_initialize :klass

  def fetch_ids
    Version
      .where("(item_diff->>:field) is not null", field: 'description')
      .where(item_type: klass.name)
      .where(state: [:accepted, :taken])
      .pluck(:item_id)
      .uniq
      .sort
  end
end
