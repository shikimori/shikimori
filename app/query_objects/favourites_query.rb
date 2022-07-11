class FavouritesQuery
  def favoured_by entry, limit
    User
      .where(id: scope(entry).limit(limit).select(:user_id))
      .order(:nickname)
  end

  def favoured_size entry
    Favourite
      .where(linked_id: entry.id, linked_type: entry.class.name)
      .size
  end

  def top_favourite_ids klass, limit
    top_favourite(klass, limit).pluck(:linked_id)
  end

  def top_favourite klass, limit
    Favourite
      .where(linked_type: klass.is_a?(Array) ? klass : klass.name)
      .group(:linked_id, :linked_type)
      .order(Arel.sql('count(*) desc'))
      .select(:linked_id, :linked_type)
      .limit(limit)
  end

  def global_top klass, limit, user
    global_top_favored_ids = FavouritesQuery.new.top_favourite_ids(klass, limit)
    ai_genre_ids = Animes::Query::GENRES_EXCLUDED_BY_SEX[user.try(:sex) || '']

    klass
      .where(id: global_top_favored_ids - user_exclude_ids(user, klass))
      .where.not(kind: %i[special music])
      .where.not("genre_ids && '{#{ai_genre_ids.join ','}}'")
      .sort_by { |v| global_top_favored_ids.index v.id }
  end

  def scope entry
    Favourite.where(linked_id: entry.id, linked_type: entry.class.name)
  end

private

  def user_exclude_ids user, klass
    user_in_list_ids(user, klass) + user_ignored_ids(user, klass)
  end

  def user_in_list_ids user, klass
    user ?
      user
        .send("#{klass.base_class.name.downcase}_rates")
        .where.not(status: UserRate.statuses['planned'])
        .pluck(:target_id) :
      []
  end

  def user_ignored_ids user, klass
    user ?
      user
        .recommendation_ignores
        .where(target_type: klass.name)
        .pluck(:target_id) :
      []
  end
end
