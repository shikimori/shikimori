class VideosController < ShikimoriController
  before_action :authenticate_user!
  before_action :fetch_anime

  def create
    @video, @version = versioneer.upload video_params, current_user

    redirect_to_back_or_to(
      @anime.decorate.edit_field_url(:screenshots),
      @video.persisted? ?
        { notice: i18n_t('pending_version') } :
        { alert: @video.errors.full_messages.join(', ') }
    )
  end

  def destroy
    @version = versioneer.delete params[:id], current_user
    render json: { notice: i18n_t('pending_version') }
  end

private

  def video_params
    params
      .require(:video)
      .permit(:url, :kind, :name)
      .merge(uploader_id: current_user.id)
  end

  def versioneer
    Versioneers::VideosVersioneer.new @anime
  end


  def fetch_anime
    @anime = Anime.find(
      CopyrightedIds.instance.restore(params[:anime_id], 'anime')
    )
  end
end
