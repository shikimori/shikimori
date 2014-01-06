class VideosController < ApplicationController
  before_filter :authenticate_user!

  def create
    @entry = Anime.find params[:id]
    @video = @entry.videos.build video_params
    @video.state = 'uploaded'

    @video.state = 'confirmed' if params[:apply].present? && current_user.user_changes_moderator?

    if @video.save
      if @video.confirmed?
        redirect_to :back
      else
        render json: {}
      end
    else
      if @video.confirmed?
        flash[:alert] = @video.errors.full_messages.join ', '
        redirect_to :back
      else
        render json: @video.errors, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @video = Video.find params[:id]
    @video.suggest_deletion current_user

    render json: {
      notice: 'Запрос на удаление принят и будет рассмотрен модератором. Домо аригато.'
    }
  end

private
  def video_params
    params
      .require(:video)
      .permit(:url, :kind, :name)
      .merge(uploader_id: current_user.id)
  end
end
