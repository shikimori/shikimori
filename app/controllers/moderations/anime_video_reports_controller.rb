class Moderations::AnimeVideoReportsController < ModerationsController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, except: [:create]
  load_and_authorize_resource except: :index

  def index
    @page_title = i18n_t 'page_title'
    @moderators = User.where(id: User::VIDEO_MODERATORS - User::ADMINS)
    @processed = processed_reports
    @pending = pending_reports unless json?
  end

  def create
    @resource.save!
    head 200
  end

  def accept
    @resource.accept! current_user if @resource.can_accept?
    redirect_back fallback_location: moderations_anime_video_reports_url
  end

  def accept_edit
    @resource.accept! current_user if @resource.can_accept?

    redirect_to edit_video_online_url(
      @resource.anime_video.anime,
      @resource.anime_video,
      host: AnimeOnlineDomain.host(@resource.anime_video.anime)
    )
  end

  def accept_broken
    if @resource.can_accept?
      @resource.accept! current_user
      @resource.anime_video.broken
    end

    redirect_back fallback_location: moderations_anime_video_reports_url
  end

  def close_edit
    @resource.accept_only! current_user if @resource.can_accept_only?

    redirect_to edit_video_online_url(
      @resource.anime_video.anime,
      @resource.anime_video,
      host: AnimeOnlineDomain.host(@resource.anime_video.anime)
    )
  end

  def reject
    @resource.reject! current_user if @resource.can_reject?
    redirect_back fallback_location: moderations_anime_video_reports_url
  end

  def work
    @resource.work! if @resource.can_work?
    redirect_back fallback_location: moderations_anime_video_reports_url
  end

  def cancel
    @resource.cancel! current_user if @resource.can_cancel?
    redirect_back fallback_location: moderations_anime_video_reports_url
  end

private

  def anime_video_report_params
    params
      .require(:anime_video_report)
      .permit(:kind, :anime_video_id, :user_id, :message)
      .merge(user_agent: request.user_agent)
  end

  def processed_reports
    postload_paginate(params[:page], 20) do
      AnimeVideoReport.includes(:user, anime_video: :author).processed
    end
  end

  def pending_reports
    AnimeVideoReport
      .includes(:user, anime_video: :author)
      .pending
      .order(id: :desc)
      .limit(20)
  end
end
