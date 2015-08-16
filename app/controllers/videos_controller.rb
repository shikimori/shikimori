class VideosController < ShikimoriController
  before_action :authenticate_user!

  def create
    @entry = Anime.find params[:id]
    @resource = @entry.videos.build video_params
    @resource.state = 'uploaded'

    @resource.state = 'confirmed' if params[:apply].present? && current_user.user_changes_moderator?

    if @resource.save
      render json: { notice: 'Видео сохранено и будет в ближайшее время рассмотрено модератором. Домо аригато.' }
    else
      render json: @resource.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @resource = Video.find params[:id]
    @resource.suggest_deletion current_user

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
