class VideosController < ApplicationController
  before_filter :authenticate_user!

  def create
    @entry = Anime.find params[:id]
    @video = @entry.videos.build params[:video].merge(uploader_id: current_user.id)
    @video.state = 'uploaded'

    @video.state = 'confirmed' if params[:apply].present? && current_user.user_changes_moderator?

    if @video.save
      if @video.state == 'confirmed'
        redirect_to :back
      else
        render json: {}
      end
    else
      if @video.state == 'confirmed'
        flash[:alert] = @video.errors.full_messages.join ', '
        redirect_to :back
      else
        render json: @video.errors, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @video = Video.find(params[:id])
    @video.suggest_deletion current_user

    render json: {
      notice: 'Запрос на удаление принят и будет рассмотрен модератором. Домо аригато.'
    }
  end
end
