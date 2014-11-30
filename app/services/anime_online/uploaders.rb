class AnimeOnline::Uploaders
  ENOUGH_TO_TRUST = 50

  def self.top
    current_top + User::TrustedVideoUploaders
  end

  def self.current_top
    AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .where(state: :accepted, kind: :uploaded)
      .group(:user_id)
      .order('videos desc')
      .limit(20)
      .map(&:user)
      #.map(&:user_id)
  end

  def self.responsible
    active_users = AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .where(kind: :uploaded)
      .group(:user_id)
      .having('count(*) >= ?', ENOUGH_TO_TRUST)
      .map(&:user_id)

    user_with_rejected = AnimeVideoReport
      .where(kind: :uploaded, state: :rejected)
      .where(user_id: active_users)
      .map(&:user_id)

    active_users - user_with_rejected
  end

  def self.trusted? user_id
    @trusted ||= (top + responsible).uniq
    @trusted.include? user_id
  end
end
