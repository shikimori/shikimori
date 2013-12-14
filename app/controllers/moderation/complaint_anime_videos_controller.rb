class Moderation::ComplaintAnimeVideosController < ApplicationController
  #before_filter :authenticate_user!
  #before_filter :check_permissions

  def index
    @page_title = 'Модерация видео'
    @messages = Message.where(dst_id: 1077, subject: [:broken_video.to_s, :wrong_video.to_s]).all
  end

  def broken
    video = AnimeVideo.find params[:id]
    render nothing: true
  end

  def wrong
    video = AnimeVideo.find params[:id]
    render nothing: true
  end

private
  def check_permissions
    raise Forbidden unless current_user.admin?
  end
end
