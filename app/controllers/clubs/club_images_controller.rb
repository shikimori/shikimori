class Clubs::ClubImagesController < ShikimoriController
  load_and_authorize_resource :club
  load_and_authorize_resource only: [:destroy]

  def create
    image = ClubImage.new(
      club: @club,
      user: current_user,
      image: params[:image]
    )
    authorize! :create, image
    image.save!

    if request.xhr?
      render json: {
        html: render_to_string(
          partial: 'club_images/club_image',
          object: image,
          locals: { rel: 'club' },
          formats: :html
        )
      }
    else
      redirect_to club_url(@club), notice: i18n_t('image_uploaded')
    end
  end

  def destroy
    @resource.destroy!
    render json: { notice: i18n_t('image_deleted') }
  end
end
