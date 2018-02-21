class Users::OauthApplicationsController < ProfilesController
  load_and_authorize_resource

  before_action do
    @back_url = profile_url @user
    og page_title: t('oauth_applications.index.title')

    if params[:action] != 'index'
      breadcrumb(
        t('oauth_applications.index.title'),
        profile_oauth_applications_url(@user)
      )
    end
  end

  UPDATE_PARAMS = %i[name image]
  CREATE_PARAMS = %i[user_id] + UPDATE_PARAMS

  def index
    @collection = @user.oauth_applications
  end

  def show
    og page_title: @resource.name
  end

  def new
    og page_title: i18n_t('new')
    render :form
  end

  def create
    if @resource.save
      redirect_to edit_profile_oauth_application_url(@user, @resource)
    else
      render :form
    end
  end

  def edit
    og page_title: @resource.name
    render :form
  end

  def update
    if @resource.update update_params
      redirect_to edit_profile_poll_url(@user, @resource)
    else
      render :form
    end
  end

  def destroy
    @resource.destroy
    redirect_to profile_polls_url(@user)
  end

private

  def create_params
    params.require(:oauth_application).permit(*CREATE_PARAMS)
  end
  alias new_params create_params

  def update_params
    params.require(:oauth_application).permit(*UPDATE_PARAMS)
  end
end
