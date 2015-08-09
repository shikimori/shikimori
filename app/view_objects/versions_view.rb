class VersionsView < ViewObjectBase
  instance_cache :moderators, :pending, :processed_query
  per_page_limit 25

  def processed
    processed_query.first
  end

  def postloader?
    processed_query.second
  end

  def pending
    Version
      .includes(:user, :moderator)
      .where(state: :pending)
      .order(:id)
      .limit(per_page_limit)
      .decorate
  end

  def next_page_url
    h.index_moderation_user_changes_url page: page+1
  end

  def moderators
    User
      .where(id: User::UserChangesModerators - User::Admins)
      .sort_by { |v| v.nickname.downcase }
  end

private

  def processed_query
    Moderation::ProcessedVersionsQuery.new
      .fetch(page, per_page_limit)
      .map(&:decorate)
  end
end
