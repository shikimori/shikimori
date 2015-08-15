class ScreenshotsController < ShikimoriController
  before_filter :authenticate_user!

  def create
    anime = Anime.find params[:id]
    @screenshot, @version = versioneer(anime).upload params[:image], current_user

    if @screenshot.persisted?
      render json: {
        html: render_to_string(@screenshot, locals: { edition: true })
      }
    else
      render json: @screenshot.errors, status: :unprocessable_entity
    end
  #rescue
    #render json: { error: 'Произошла ошибка при загрузке файла. Пожалуйста, повторите попытку, либо свяжитесь с администрацией сайта.' }
  end

  def destroy
    @screenshot = Screenshot.find(params[:id])

    if @screenshot.status == Screenshot::Uploaded
      @screenshot.destroy
      render json: { notice: i18n_t('screenshot_deleted') }
    else
      @version = versioneer(@screenshot.anime).delete @screenshot.id, current_user
      render json: { notice: i18n_t('pending_deletion') }
    end
  end

private

  def versioneer anime
    Versioneers::ScreenshotsVersioneer.new anime
  end
end
