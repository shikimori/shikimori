class ScreenshotsController < ShikimoriController
  before_filter :authenticate_user!

  def create
    @entry = Anime.find params[:id]
    image = params[:image]# || File.open('/home/morr/Pictures/Workspace 1_042.png')

    unless %x(file #{image.tempfile.path}) =~ /image/
      render json: { error: 'Загруженный файл не является изображением' }
      return
    end

    @screenshot = @entry.screenshots.build({
      image: image,
      position: 99999,
      url: rand()
    })
    @screenshot.status = Screenshot::Uploaded

    if @screenshot.save
      @screenshot.suggest_acception(current_user)
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
      render json: { notice: 'Скриншот удалён.' }
    else
      @screenshot.suggest_deletion current_user
      render json: { notice: 'Запрос на удаление принят и будет рассмотрен модератором. Домо аригато.' }
    end
  end

private

  # класс текущего элемента
  def klass
    @klass ||= Object.const_get(self.class.name.underscore.split('_')[0].singularize.camelize)
  end
end
