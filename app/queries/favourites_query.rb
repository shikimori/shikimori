class FavouritesQuery
  def top_favourite_ids klass, limit
    top_favourite(klass, limit).pluck(:linked_id)
  end

  def top_favourite klass, limit
    Favourite
      .where(linked_type: klass.name)
      .group(:linked_id)
      .order('count(*) desc')
      .select(:linked_id)
      .limit(limit)
  end

  # получение списка людей, добавивших сущность в избранное
  def favoured_by entry, limit
    User
      .where(id: user_ids(entry, limit))
      .order(:nickname)
  end

private
  def user_ids entry, limit
    Favourite
      .where(linked_id: entry.id, linked_type: entry.class.name)
      .group(:user_id)
      .limit(limit)
      .pluck(:user_id)
  end
end
