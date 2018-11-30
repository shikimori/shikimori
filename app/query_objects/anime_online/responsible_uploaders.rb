class AnimeOnline::ResponsibleUploaders
  method_object

  UPLOADS_TO_TRUST = 25
  TRUST_THRESHOLD = 0.95

  def call
    active_users
      .select do |user_id, accepts|
        1 - (user_with_rejects[user_id] || 0) * 1.0 / accepts >= TRUST_THRESHOLD
      end
      .map(&:first)
  end

private

  def active_users
    @active_users ||= AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .where(kind: :uploaded)
      .group(:user_id)
      .having('count(*) >= ?', UPLOADS_TO_TRUST)
      .select('user_id, count(*) as uploads')
      .each_with_object({}) { |v, memo| memo[v.user_id] = v.uploads }
  end

  def user_with_rejects
    @user_with_rejects ||= AnimeVideoReport
      .where(kind: :uploaded, state: :rejected)
      .where(user_id: active_users.map(&:first))
      .group(:user_id)
      .select('user_id, count(*) as rejects')
      .each_with_object({}) { |v, memo| memo[v.user_id] = v.rejects }
  end
end
