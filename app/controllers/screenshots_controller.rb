class ScreenshotsController < ShikimoriController
  before_action :authenticate_user!
  before_action :fetch_anime

  def create # rubocop:disable all
    @screenshot, @version = versioneer.upload params[:image], current_user
    @version.auto_accept! if may_accept? @version

    @screenshot.destroy! if @screenshot.persisted? && !@version.persisted?

    if @screenshot.persisted?
      render json: {
        html: render_to_string(@screenshot, locals: { edition: true })
      }
    else
      errors = (@screenshot.destroyed? ? @version : @screenshot).errors.full_messages
      render json: errors.join(', '), status: :unprocessable_entity
    end
  end

  def destroy # rubocop:disable AbcSize
    @screenshot = Screenshot.find(params[:id])

    if @screenshot.status == Screenshot::UPLOADED
      @screenshot.destroy
      render json: { notice: i18n_t('screenshot_deleted') }
    else
      @version = versioneer.delete @screenshot.id, current_user
      @version.auto_accept! if may_accept? @version

      if @version.persisted?
        render json: { notice: i18n_t('pending_version') }
      else
        render json: @version.errors.full_messages, status: :unprocessable_entity
      end
    end
  end

  def reposition
    @version = versioneer.reposition params[:ids].split(','), current_user
    @version.auto_accept! if may_accept? @version

    redirect_back(
      fallback_location: @anime.decorate.edit_field_url(:screenshots),
      notice: i18n_t('pending_version')
    )
  end

private

  def versioneer
    Versioneers::ScreenshotsVersioneer.new @anime
  end

  def fetch_anime
    @anime = Anime.find(
      CopyrightedIds.instance.restore(params[:anime_id], 'anime')
    )
  end

  def may_accept? version
    version&.persisted? && version&.may_auto_accept? &&
      can?(:auto_accept, version)
  end
end
