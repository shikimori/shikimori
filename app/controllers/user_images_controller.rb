class UserImagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    #linked = params[:linked_type].constantize.find params[:linked_id]
    @image = UserImage.new
    @image.user = current_user
    @image.image = params[:image]

    if @image.save
      render json: {
        id: @image.id,
        preview: @image.image.url(:preview, false),
        url: @image.image.url(:original, false)
      }
      #render json: {
        #html: render_to_string(partial: 'images/image', object: @image, locals: { group_name: 'images', style: :main }, formats: :html)
      #}
    else
      render json: @image.errors.messages, status: :unprocessable_entity
    end
  rescue
    render json: { error: 'Произошла ошибка при загрузке файла. Пожалуйста, повторите попытку, либо свяжитесь с администрацией сайта.' }, status: :unprocessable_entity
  end
end
