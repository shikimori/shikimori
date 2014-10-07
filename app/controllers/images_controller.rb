class ImagesController < ShikimoriController
  load_and_authorize_resource

  # создание картинки
  #def create
    #owner = params[:model].capitalize.constantize.find params[:id]

    #@image = Image.new
    #@image.owner = owner
    #@image.uploader = current_user
    #@image.image = params[:image]

    #if @image.save
      #render json: {
        #html: render_to_string(partial: 'images/image', object: @image, locals: { group_name: 'images', style: :main }, formats: :html)
      #}
    #else
      #render json: @image.errors.messages, status: :unprocessable_entity
    #end
  #rescue
    #render json: { error: 'Произошла ошибка при загрузке файла. Пожалуйста, повторите попытку, либо свяжитесь с администрацией сайта.' }, status: :unprocessable_entity
  #end

  # содержимое картинки
  #def raw
    #@image = Image.find(params[:id])
    #raise Forbidden unless @image.uploader_id == current_user.id

    #response.headers['Content-Type'] = 'image/jpeg'
    #render text: File.read(@image.image.path(:original))
  #end

  # удаление картинки
  def destroy
    @resource.destroy!
    render json: { notice: 'Изображение удалено' }
  end
end
