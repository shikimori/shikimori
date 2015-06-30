# выборка из базы id элементов с пользовательскими правками
class ChangedItemsQuery
  pattr_initialize :klass

  def fetch_ids
    UserChange
      .where(model: klass.name, column: 'description')
      .where(status: [UserChangeStatus::Accepted, UserChangeStatus::Taken])
      .pluck(:item_id)
      .uniq
  end
end
