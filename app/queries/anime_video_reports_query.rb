class AnimeVideoReportsQuery
  def self.top_uploaders
    AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .where(state: :accepted, kind: :uploaded)
      .group(:user_id)
      .order('videos desc')
      .limit(20)
      .map(&:user)
  end
end
