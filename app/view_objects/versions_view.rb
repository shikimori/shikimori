class VersionsView < ViewObjectBase
  instance_cache :moderators, :pending, :processed, :processed_query
  per_page_limit 25

  def processed
    processed_query.first.map(&:decorate)
  end

  def postloader?
    processed_query.second
  end

  def pending
    Version
      .includes(:user, :moderator)
      .where(state: :pending)
      .order(:created_at)
      .limit(per_page_limit)
      .decorate
  end

  def next_page_url
    h.index_moderation_versions_url page: page+1
  end

  def moderators
    User
      .where(id: User::UserChangesModerators - User::Admins)
      .sort_by { |v| v.nickname.downcase }
  end

private

  def processed_query
    Moderation::ProcessedVersionsQuery.new.postload page, per_page_limit
  end
end
