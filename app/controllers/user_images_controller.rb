class UserImagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @image = UserImage.new
    @image.user = current_user
    @image.image = params[:image]
    @image.linked_type = params[:linked_type]
    #linked = params[:linked_type].constantize.find params[:linked_id]

    if @image.save
      render json: {
        id: @image.id,
        preview: @image.image.url(:preview, false),
        url: @image.image.url(:original, false)
      }
    else
      render json: @image.errors.messages, status: :unprocessable_entity
    end

  rescue
    render json: { error: 'Произошла ошибка при загрузке файла. Пожалуйста, повторите попытку, либо свяжитесь с администрацией сайта.' }, status: :unprocessable_entity
  end
end
