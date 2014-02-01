class FavouritesQuery
  def initialize(entry, limit)
    @entry = entry
    @limit = limit
  end

  # получение списка людей, добавивших сущность в избранное
  def fetch
    Favourite.where(linked_id: @entry.id, linked_type: @entry.class.name)
        .includes(:user)
        .group(:user_id)
        .order('rand()')
        .limit(@limit)
        .sort_by {|v| v.user.nickname }
  end
end
