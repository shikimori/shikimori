class Moderation::ComplaintAnimeVideosController < ApplicationController
  #before_filter :authenticate_user!
  #before_filter :check_permissions

  def index
    @page_title = 'Модерация видео'
    @messages = Message.where(dst_id: 1077, subject: [:broken_video.to_s, :wrong_video.to_s]).all
    # replace kind on state
    @complaint_videos = AnimeVideo.where(kind: [:broken.to_s, :wrong.to_s]).order('updated_at desc').all
  end

  def broken
    video = AnimeVideo.find params[:id]
    render nothing: true
  end

  def wrong
    video = AnimeVideo.find params[:id]
    render nothing: true
  end

  def ignore
    message = Message.find params[:id]
    #message.delete
    render nothing: true
    #redirect_to_back_or_to moderation_complaint_anime_videos_url
    #redirect_to root_url
  end

  def reset
    video = AnimeVideo.find params[:id]
    render nothing: true
  end

private
  def check_permissions
    raise Forbidden unless current_user.admin?
  end
end
