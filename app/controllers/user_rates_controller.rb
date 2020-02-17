class UserRatesController < ProfilesController
  load_and_authorize_resource except: %i[index]

  before_action :check_access, only: %i[index]
  before_action :set_sort_order, only: %i[index], if: :user_signed_in?
  after_action :save_sort_order, only: %i[index], if: :user_signed_in?

  skip_before_action :fetch_resource, :set_breadcrumbs,
    except: %i[index]

  def index
    og noindex: true

    @library = UserLibraryView.new @resource
    @menu = Menus::CollectionMenu.new @library.klass

    og page_title: t("#{params[:list_type]}_list")
  end

  def edit
  end

private

  # def create_params
    # params
      # .require(:user_rate)
      # .permit(*Api::V1::UserRatesController::CREATE_PARAMS)
  # end

  # def update_params
    # params
      # .require(:user_rate)
      # .permit(*Api::V1::UserRatesController::UPDATE_PARAMS)
  # end

  def check_access
    authorize! :access_list, @resource
  end

  def set_sort_order
    return if params[:order].present?

    if current_user.preferences.default_sort == Animes::Filters::OrderBy::DEFAULT_ORDER
      params[:order] = current_user.preferences.default_sort
    else
      redirect_to current_url(order: current_user.preferences.default_sort)
    end
  end

  def save_sort_order
    if params[:order] && current_user.preferences.default_sort != params[:order]
      current_user.preferences.update default_sort: params[:order]
    end
  end
end
