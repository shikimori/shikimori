class Users::ListImportsController < ProfilesController
  load_and_authorize_resource
  before_action do
    @back_url = edit_profile_url @user, page: :list
    breadcrumb t(:settings), edit_profile_url(@user, page: :list)
    page_title t(:settings)
  end

  def new
  end

  def create
    if @resource.save
      redirect_to list_import_url(@resource)
    else
      render :new
    end
  end

  def show
  end

private

  def list_import_params
    params
      .require(:list_import)
      .permit(:user_id, :list)
  end
end
