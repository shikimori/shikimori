class AnimeOnline::Uploaders
  ENOUGH_TO_TRUST = 50

  # FIX : Проверить использование этого метода, если пусто, то удалить. / @Blackchestnut /
  def self.top
    current_top + User::TrustedVideoUploaders
  end

  def self.current_top limit=20, is_adult=nil
    AnimeOnline::Contributors.uploaders_top(limit, is_adult)
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

  def self.reset
    @trusted = nil
  end
end
