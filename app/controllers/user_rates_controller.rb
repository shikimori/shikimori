class UserRatesController < ProfilesController
  load_and_authorize_resource except: %i[index]

  before_action :check_access, only: %i[index]
  before_action :set_sort_order, only: %i[index], if: :user_signed_in?
  after_action :save_sort_order, only: %i[index], if: :user_signed_in?

  skip_before_action :fetch_resource, :set_breadcrumbs,
    except: %i[index]
  helper_method :scores_options, :statuses_options

  SortOrder = Animes::Filters::OrderBy::Field

  def index
    og noindex: true
    og page_title: t("#{params[:list_type]}_list")

    @library = Profiles::LibraryView.new @resource
    @menu = Menus::CollectionMenu.new @library.klass

    # additional check fo sort order an trigger Dry::Types::ConstraintError in case of invalid value
    SortOrder[@library.sort_order]
    # just call to init params parsing and potential redirect if params are invalid
    @library.any?
  rescue Dry::Types::ConstraintError
    redirect_to current_url(order: SortOrder[:rate_score])
  end

  def edit
    render :edit, formats: :html
  end

private

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

  def scores_options
    @scores ||= {}
    @scores[I18n.locale] ||= 1.upto(10).map do |score|
      ["(#{score}) #{I18n.t("activerecord.attributes.user_rate.scores.#{score}")}", score]
    end
  end

  def statuses_options target_type
    UserRate.statuses.map do |status_name, _status_id|
      [UserRate.status_name(status_name, target_type), status_name]
    end
  end
end
