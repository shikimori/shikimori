class VideosController < ShikimoriController
  before_action :authenticate_user!
  before_action :fetch_anime

  def create # rubocop:disable all
    @video, @version = versioneer.upload create_params, current_user
    @version.auto_accept! if @version&.persisted? && can?(:auto_accept, @version)

    @video.destroy! if @video.persisted? && !@version.persisted? && params[:anime_id] != '0'

    if request.xhr?
      replace_video @video if duplicate? @video
    else
      if @video.persisted?
        flash_key = :notice
        flash_value = i18n_t('pending_version')
      else
        flash_key = :alert
        flash_value = (@video.destroyed? ? @version : @video).errors.full_messages.join(', ')
      end

      redirect_back(
        fallback_location: @anime.decorate.edit_field_url(:videos),
        flash_key => flash_value
      )
    end
  end

  # method based on code from DbEntriesController#update
  def update # rubocop:disable MethodLength
    @video = @anime.videos.find params[:id]

    Version.transaction do
      @version = create_version
      authorize! :create, @version
    end

    if @version.persisted?
      redirect_to(
        edit_field_anime_url(@anime, field: 'videos'),
        notice: i18n_t("version_#{@version.state}")
      )
    else
      redirect_back(
        fallback_location: edit_video_anime_url(@anime, @video),
        alert: @version.errors[:base]&.dig(0) || i18n_t('no_changes')
      )
    end
  end

  def destroy
    @version = versioneer.delete params[:id], current_user

    if @version.persisted?
      render json: { notice: i18n_t('pending_version') }
    else
      render json: @version.errors.full_messages, status: :unprocessable_entity
    end
  end

private

  def create_params
    update_params.merge(uploader_id: current_user.id)
  end

  def update_params
    params
      .require(:video)
      .permit(:url, :kind, :name)
  end

  def versioneer
    Versioneers::VideosVersioneer.new @anime
  end

  def fetch_anime
    @anime = Anime.find_by(
      id: CopyrightedIds.instance.restore(params[:anime_id], 'anime')
    )
  end

  def duplicate? video
    video.errors.one? &&
      video.errors[:url] == Array(I18n.t('activerecord.errors.messages.taken'))
  end

  def replace_video video
    @video = Video.find_by url: video.url
  end

  def create_version
    version = Versioneers::FieldsVersioneer
      .new(@video, associated: @anime)
      .premoderate(
        update_params.is_a?(Hash) ? update_params : update_params.to_unsafe_h,
        current_user,
        params[:reason]
      )

    version.auto_accept! if version.persisted? && can?(:auto_accept, version)
    version
  rescue StateMachineRollbackError
    version.destroy
    version
  end
end
