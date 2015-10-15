class Api::V1::UserImagesController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/user_images', 'Create an user image'
  param :image, :undef
  param :linked_type, :undef
  def create
    @resource = UserImage.new do |image|
      image.user = current_user
      image.image = uploaded_image
      image.linked_type = params[:linked_type]
    end
    #linked = params[:linked_type].constantize.find params[:linked_id]

    if @resource.save
      render json: {
        id: @resource.id,
        preview: @resource.image.url(:preview, false),
        url: @resource.image.url(:original, false),
        bbcode: "[image=#{@resource.id}]"
      }
    else
      render json: @resource.errors.messages, status: :unprocessable_entity
    end
  end

private

  def uploaded_image
    params[:image]
  end
end
