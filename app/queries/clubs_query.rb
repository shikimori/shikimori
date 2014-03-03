class ClubsQuery
  def fetch page, limit
    Group
      .joins(:member_roles, :thread)
      .group('groups.id')
      .having('count(group_roles.id) > 0')
      .order('entries.updated_at desc')
      .offset(limit * (page-1))
      .limit(limit + 1)
  end

  def postload page, limit
    collection = fetch(page, limit).to_a
    [collection.take(limit), collection.size == limit+1]
  end
end
