class Moderation::ComplaintAnimeVideosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_permissions

  def index
    @page_title = 'Модерация видео'
    @messages = AnimeVideoComplaintDecorator.decorate_collection Message.complaint_videos.all
    @complaint_videos = AnimeVideo.where(state: [:broken.to_s, :wrong.to_s]).order('updated_at desc').all
  end

  def broken
    AnimeVideo.find(params[:video_id]).broken!
    Message.delete params[:id]
    redirect_to_back_or_to moderation_complaint_anime_videos_url
  end

  def wrong
    AnimeVideo.find(params[:video_id]).wrong!
    Message.delete params[:id]
    redirect_to_back_or_to moderation_complaint_anime_videos_url
  end

  def ignore
    Message.delete params[:id]
    redirect_to_back_or_to moderation_complaint_anime_videos_url
  end

  def work
    AnimeVideo.find(params[:id]).work!
    redirect_to_back_or_to moderation_complaint_anime_videos_url
  end

private
  def check_permissions
    raise Forbidden unless current_user.video_moderator?
  end
end
