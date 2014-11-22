class VideosController < ShikimoriController
  before_filter :authenticate_user!

  def create
    @entry = Anime.find params[:id]
    @video = @entry.videos.build video_params
    @video.state = 'uploaded'

    @video.state = 'confirmed' if params[:apply].present? && current_user.user_changes_moderator?

    if @video.save
      render json: { notice: 'Видео сохранено и будет в ближайшее время рассмотрено модератором. Домо аригато.' }
    else
      render json: @video.errors, status: :unprocessable_entity
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
