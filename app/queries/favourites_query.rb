class FavouritesQuery
  def initialize entry, limit
    @entry = entry
    @limit = limit
  end

  # получение списка людей, добавивших сущность в избранное
  def fetch
    User
      .where(id: user_ids)
      .order(:nickname)
  end

  def user_ids
    Favourite
      .where(linked_id: @entry.id, linked_type: @entry.class.name)
      .group(:user_id)
      .limit(@limit)
      .pluck(:user_id)
  end
end
