class Moderation::AnimeVideoReportsController < ShikimoriController
  before_filter :authenticate_user!
  before_filter :check_permissions

  def index
    @page_title = 'Модерация видео'
    @processed = postload_paginate(params[:page], 20) do
      AnimeVideoReport.includes(:user, anime_video: :author).processed
    end

    unless json?
      @pending = AnimeVideoReport.includes(:user, anime_video: :author).pending.limit(20)
    end
  end

  def accept
    AnimeVideoReport.find(params[:id]).accept! current_user
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

  def reject
    AnimeVideoReport.find(params[:id]).reject! current_user
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

  def work
    AnimeVideo.find(params[:id]).work!
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

  def cancel
    AnimeVideoReport.find(params[:id]).cancel! current_user
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

private
  def check_permissions
    raise Forbidden unless current_user.video_moderator?
  end
end
