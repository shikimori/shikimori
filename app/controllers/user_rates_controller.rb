class UserRatesController < ProfilesController
  load_and_authorize_resource except: %i[index]

  before_action :authorize_list_access, only: %i[index]
  before_action :set_sort_order, only: %i[index], if: :user_signed_in?
  after_action :save_sort_order, only: %i[index], if: :user_signed_in?

  skip_before_action :fetch_resource, :set_breadcrumbs,
    except: %i[index]

  def index
    noindex

    @page = (params[:page] || 1).to_i
    @limit = UserLibraryView::ENTRIES_PER_PAGE

    @library = UserLibraryView.new @resource
    @menu = Menus::CollectionMenu.new @library.klass

    page_title t("#{params[:list_type]}_list")
  end

  def edit
  end

private

  def create_params
    params
      .require(:user_rate)
      .permit(*Api::V1::UserRatesController::CREATE_PARAMS)
  end

  def update_params
    params
      .require(:user_rate)
      .permit(*Api::V1::UserRatesController::UPDATE_PARAMS)
  end

  def authorize_list_access
    authorize! :access_list, @resource
  end

  def set_sort_order
    params[:order] ||= current_user.preferences.default_sort
  end

  def save_sort_order
    if current_user.preferences.default_sort != params[:order]
      current_user.preferences.update default_sort: params[:order]
    end
  end
end
