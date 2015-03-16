class Moderation::AnimeVideoReportsController < ShikimoriController
  load_and_authorize_resource

  def index
    @page_title = 'Модерация видео'
    @processed = postload_paginate(params[:page], 20) do
      AnimeVideoReport.includes(:user, anime_video: :author).processed
    end

    unless json?
      @pending = AnimeVideoReport
        .includes(:user, anime_video: :author)
        .pending
        .order(id: :desc)
        .limit(20)
    end
  end

  def create
    @resource.save!
    head 200
  end

  def accept
    @resource.accept! current_user
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

  def accept_edit
    @resource.accept! current_user
    redirect_to edit_video_online_url(
      @resource.anime_video.anime_id,
      @resource.anime_video,
      host: AnimeOnlineDomain.host(@resource.anime_video.anime)
    )
  end

  def accept_cut_vk_hd
    @resource.accept! current_user
    AnimeOnline::VideoVkService.new(@resource.anime_video).cut_hd!
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

  def reject
    @resource.reject! current_user
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

  def work
    @resource.work!
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

  def cancel
    @resource.cancel! current_user
    redirect_to_back_or_to moderation_anime_video_reports_url
  end

private
  def anime_video_report_params
    params
      .require(:anime_video_report)
      .permit(:kind, :anime_video_id, :user_id, :message)
      .merge(user_agent: request.user_agent)
  end
end
