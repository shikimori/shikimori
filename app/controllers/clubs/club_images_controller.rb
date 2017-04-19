class Clubs::ClubImagesController < ShikimoriController
  load_and_authorize_resource :club
  load_and_authorize_resource only: [:destroy]

  def create
    if request.xhr?
      @resource = create_image params[:image]
      render json: ClubImageSerializer.new(@resource).to_json

    else
      params[:images].each { |image| create_image image }
      redirect_to club_url(@club), notice: i18n_t('image_uploaded')
    end
  end

  def destroy
    @resource.destroy!
    render json: { notice: i18n_t('image_deleted') }
  end

private

  def create_image uploaded_file
    image = ClubImage.new(
      club: @club,
      user: current_user,
      image: uploaded_file
    )
    authorize! :create, image
    image.save!
    image
  end
end
