class AnimeOnline::StatisticsController < ApplicationController
  layout 'anime_online'

  def uploaders
      #.where(state: :accepted)
    @users = AnimeVideoReport
      .select(:user_id, 'count(*) as videos')
      .group(:user_id)
      .order('videos desc')
      .limit(20)
      .collect(&:user)
  end
end
