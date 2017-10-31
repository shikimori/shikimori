class AnimeOnline::ResponsibleUploaders
  method_object

  UPLOADS_TO_TRUST = 50

  def call
    active_users - user_with_rejects
  end

private

  def active_users
    AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .where(kind: :uploaded)
      .group(:user_id)
      .having('count(*) >= ?', UPLOADS_TO_TRUST)
      .map(&:user_id)
  end

  def user_with_rejects
    AnimeVideoReport
      .where(kind: :uploaded, state: :rejected)
      .where(user_id: active_users)
      .map(&:user_id)
  end
end
