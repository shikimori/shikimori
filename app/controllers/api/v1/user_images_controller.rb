class Api::V1::UserImagesController < Api::V1Controller
  before_action do
    doorkeeper_authorize! :comments if doorkeeper_token.present?
  end

  api :POST, '/user_images', 'Create an user image'
  description 'Requires `comments` oauth scope'
  param :image, :undef, require: true
  param :linked_type, String, require: true
  def create # rubocop:disable all
    if Rails.env.development? && params[:test]
      dev_user = User.find params[:test]
    else
      authenticate_user!
    end

    @resource = UserImage.new do |image|
      image.user = dev_user || current_user
      image.image = uploaded_image
      image.linked_type = params[:linked_type]
    end
    # linked = params[:linked_type].constantize.find params[:linked_id]

    if @resource.save
      render json: {
        id: @resource.id,
        preview: @resource.image.url(:preview, false),
        url: @resource.image.url(:original, false),
        bbcode: "[image=#{@resource.id}]"
      }
    else
      render json: @resource.errors.full_messages, status: :unprocessable_entity
    end
  end

private

  def uploaded_image
    params[:image]
  end
end
