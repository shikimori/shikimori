class UserRatesController < ProfilesController
  load_and_authorize_resource except: [:index]
  skip_before_action :fetch_resource, :set_breadcrumbs, except: [:index]

  def index
  end

  def create
    @user_rate.save rescue PG::Error
    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def edit
  end

  def update
    @user_rate.update update_params
    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def increment
    if @user_rate.anime?
      @user_rate.update episodes: @user_rate.episodes + 1
    else
      @user_rate.update chapters: @user_rate.chapters + 1
    end

    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def destroy
    @user_rate.destroy!
    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

private
  def create_params
    params.require(:user_rate).permit(*Api::V1::UserRatesController::CREATE_PARAMS)
  end

  def update_params
    params.require(:user_rate).permit(*Api::V1::UserRatesController::UPDATE_PARAMS)
  end
end
