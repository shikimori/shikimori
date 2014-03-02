class AnimeOnline::StatisticsController < ApplicationController
  layout 'anime_online'

  def uploaders
    @users = AnimeVideoReportsQuery.top_uploaders
  end
end
