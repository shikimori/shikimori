class Moderation::ComplaintAnimeVideosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_permissions

  def index
    @page_title = 'Модерация видео'
    @messages = Message.complaint_videos.all
    @complaint_videos = AnimeVideo.where(state: [:broken.to_s, :wrong.to_s]).order('updated_at desc').all
  end

  def broken
    AnimeVideo.find(params[:id]).broken
    render nothing: true
  end

  def wrong
    AnimeVideo.find(params[:id]).wrong
    render nothing: true
  end

  def ignore
    message = Message.find params[:id]
    message.delete
    render nothing: true
    #redirect_to_back_or_to moderation_complaint_anime_videos_url
    #redirect_to root_url
  end

  def work
    AnimeVideo.find(params[:id]).work
    render nothing: true
  end

private
  def check_permissions
    raise Forbidden unless current_user.admin?
  end
end
