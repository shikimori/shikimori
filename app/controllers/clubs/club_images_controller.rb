class Clubs::ClubImagesController < ShikimoriController
  load_and_authorize_resource :club
  load_and_authorize_resource only: [:destroy]

  def create
    @resource = ClubImage.new(
      club: @club,
      user: current_user,
      image: params[:image]
    )
    authorize! :create, @resource
    @resource.save!

    if request.xhr?
      render json: ClubImageSerializer.new(@resource).to_json
    else
      redirect_to club_url(@club), notice: i18n_t('image_uploaded')
    end
  end

  def destroy
    @resource.destroy!
    render json: { notice: i18n_t('image_deleted') }
  end
end
