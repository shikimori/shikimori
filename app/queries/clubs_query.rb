class ClubsQuery < QueryObjectBase
private
  def query
    Group
      .joins(:member_roles, :thread)
      .group('groups.id, entries.updated_at')
      .having('count(group_roles.id) > 0')
      .order('entries.updated_at desc, id')
  end
end
