class ClubsQuery < QueryObjectBase
private
  def query
    Club
      .joins(:member_roles, :thread)
      .preload(:owner, :thread)
      .group('clubs.id, entries.updated_at')
      .having('count(club_roles.id) > 0')
      .order('entries.updated_at desc, id')
  end
end
