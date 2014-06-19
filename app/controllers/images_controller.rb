class ImagesController < ShikimoriController
  before_filter :authenticate_user!

  # редактирование картинки
  def edit
    @image = Image.find(params[:id])

    raise Forbidden unless @image.uploader_id == current_user.id
    @page_title = params[:original] ?
      (@image.geometry(:original).width != @image.geometry(:main).width ?
        'Загружено новое изображение [%dx%d] -> [%dx%d]' % [@image.geometry(:original).width, @image.geometry(:original).height, @image.geometry(:main).width, @image.geometry(:main).height] :
        'Загружено новое изображение [%dx%d]' % [@image.geometry(:original).width, @image.geometry(:original).height]) :
      'Изменение изображения [%dx%d]' % [@image.geometry(:main).width, @image.geometry(:main).height]
  end

  # создание картинки
  def create
    owner = params[:model].capitalize.constantize.find params[:id]

    @image = Image.new
    @image.owner = owner
    @image.uploader = current_user
    @image.image = params[:image]

    if @image.save
      render json: {
        html: render_to_string(partial: 'images/image', object: @image, locals: { group_name: 'images', style: :main }, formats: :html)
      }
    else
      render json: @image.errors.messages, status: :unprocessable_entity
    end
  rescue
    render json: { error: 'Произошла ошибка при загрузке файла. Пожалуйста, повторите попытку, либо свяжитесь с администрацией сайта.' }, status: :unprocessable_entity
  end

  # старое создание картинки
  def new
    params[:image][:uploader_id] = current_user.id
    owner = params[:image][:owner] = Object.const_get(params[:model].capitalize).find(params[:id])

    if owner.respond_to?(:can_be_uploaded_by?)
      raise Forbidden unless owner.can_be_uploaded_by?(current_user)
    end

    @image = Image.new
    @image.owner = owner
    @image.uploader = current_user
    @image.image = params[:image][:image]
    @image.save!

    redirect_to url_for(owner)
  end

  # изменение картинки
  def update
    @image = Image.find(params[:id])
    raise Forbidden unless @image.uploader_id == current_user.id
    @image.update_attributes(params[:image])
    redirect_to edit_image_url(@image)
  end

  # содержимое картинки
  def raw
    @image = Image.find(params[:id])
    raise Forbidden unless @image.uploader_id == current_user.id

    response.headers['Content-Type'] = 'image/jpeg'
    render text: File.read(@image.image.path(:original))
  end

  # удаление картинки
  def destroy
    @image = Image.find(params[:id])
    raise Forbidden unless @image.can_be_deleted_by?(current_user)
    owner = @image.owner
    @image.destroy

    respond_to do |format|
      format.html { redirect_to owner }
      format.json { render json: { notice: 'Картинка удалена' } }
    end
  end
end
