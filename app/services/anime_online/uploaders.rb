class AnimeOnline::Uploaders
  def self.top
    @top ||= (current_top + User::TrustedVideoUploaders).uniq
  end

  def self.current_top
    AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .where(state: :accepted, kind: :uploaded)
      .group(:user_id)
      .order('videos desc')
      .limit(20)
      .map(&:user_id)
  end
end
