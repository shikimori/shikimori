class AnimeOnline::StatisticsController < ApplicationController
  layout 'anime_online'

  def uploaders
    @users = AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .where(state: :accepted, kind: :uploaded)
      .group(:user_id)
      .order('videos desc')
      .limit(20)
      .collect(&:user)
  end
end
