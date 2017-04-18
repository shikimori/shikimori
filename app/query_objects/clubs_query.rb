class ClubsQuery < SimpleQueryBase
  pattr_initialize :locale

  FAVOURITES = [72, 19, 202, 113, 315, 903]

  def favourite
    clubs.where(id: FAVOURITES)
  end

  def fetch page, limit, with_favourites = false
    query(with_favourites)
      .offset(limit * (page - 1))
      .limit(limit + 1)
  end

  def query with_favourites
    if with_favourites
      clubs
    else
      clubs.where.not(id: FAVOURITES)
    end
  end

private

  def clubs
    Club
      .joins(:member_roles, :topics)
      .preload(:owner, :topics)
      .where(locale: @locale)
      .group('clubs.id, topics.updated_at')
      .having('count(club_roles.id) > 0')
      .order('topics.updated_at desc, id')
  end
end
