class ClubsQuery < QueryObjectBase
  def query
    Club
      .joins(:member_roles, :topic)
      .preload(:owner, :topic)
      .group('clubs.id, entries.updated_at')
      .having('count(club_roles.id) > 0')
      .order('entries.updated_at desc, id')
  end
end
