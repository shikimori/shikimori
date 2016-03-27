class ClubsQuery < SimpleQueryBase
  FAVOURITE = [72, 19, 202, 113, 315, 293]

  def favourite
    clubs.where(id: FAVOURITE)
  end

  def query
    clubs.where.not(id: FAVOURITE)
  end

private

  def clubs
    Club
      .joins(:member_roles, :topic)
      .preload(:owner, :topic)
      .group('clubs.id, entries.updated_at')
      .having('count(club_roles.id) > 0')
      .order('entries.updated_at desc, id')
  end
end
