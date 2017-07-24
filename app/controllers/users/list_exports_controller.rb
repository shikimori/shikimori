class Users::ListExportsController < ProfilesController
  before_action :authenticate_user!
  before_action do
    @back_url = edit_profile_url @user, page: :list
    breadcrumb t(:settings), edit_profile_url(@user, page: :list)
    page_title t(:settings)
  end

  def show
    page_title i18n_t(:title)
  end
end
