class FavouritesQuery
  def top_favourite_ids klass, limit
    top_favourite(klass, limit).pluck(:linked_id)
  end

  def top_favourite klass, limit
    Favourite
      .where(linked_type: klass.kind_of?(Array) ? klass : klass.name)
      .group(:linked_id, :linked_type)
      .order('count(*) desc')
      .select(:linked_id, :linked_type)
      .limit(limit)
  end

  def global_top klass, limit, user
    fav_ids = FavouritesQuery.new.top_favourite_ids(klass, limit)

    in_list_ids = !user ? [] : user
      .send("#{klass.name.downcase}_rates")
      .where.not(status: UserRate.statuses['planned'])
      .pluck(:target_id)

    ignored_ids = !user ? [] : user
      .recommendation_ignores
      .where(target_type: klass.name)
      .pluck(:target_id)

    klass
      .where(id: fav_ids - in_list_ids - ignored_ids)
      .where.not(kind: 'Special')
      .where.not(kind: 'Music')
      .sort_by {|v| fav_ids.index v.id }
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
