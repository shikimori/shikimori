class UserHistoryController < ProfilesController
  load_and_authorize_resource only: %i[destroy]
  before_action :check_access!, only: %i[index logs]

  LOGS_LIMIT = 45
  TYPES = Types::Strict::String.enum('anime', 'manga')

  def index
    redirect_to @resource.url if @resource.history.none?
    og noindex: true
    og page_title: i18n_t('page_title.history')

    @profile_view = @view
    @view = UserHistoryView.new @resource
  end

  def logs
    og noindex: true
    og page_title: i18n_t('page_title.logs')
    breadcrumb i18n_t('page_title.history'), profile_list_history_url(@resource)
    @back_url = profile_list_history_url(@resource)

    @collection = QueryObjectBase
      .new(@resource.user_rate_logs.order(id: :desc).includes(:target, :oauth_application))
      .paginate(@page, LOGS_LIMIT)
  end

  def destroy
    @resource.destroy
    @user.touch :rate_at

    if request.xhr?
      head :ok
    else
      redirect_to profile_list_history_url(@user)
    end
  end

  def reset # rubocop:disable MethodLength, AbcSize
    authorize! :edit, @resource

    @resource.object.history.where.not("#{TYPES[params[:type]]}_id": nil).delete_all
    @resource.object.history
      .where(
        action: [
          "mal_#{params[:type]}_import",
          "ap_#{params[:type]}_import",
          clear_action
        ]
      )
      .delete_all
    @resource.object.history.create! action: clear_action
    @resource.touch :rate_at

    render json: {
      notice: "Выполнена очистка твоей истории по #{anime? ? 'аниме' : 'манге'}"
    }
  end

private

  def anime?
    TYPES[params[:type]] == TYPES['anime']
  end

  def clear_action
    if anime?
      UserHistoryAction::ANIME_HISTORY_CLEAR
    else
      UserHistoryAction::MANGA_HISTORY_CLEAR
    end
  end

  def check_access!
    authorize! :access_list, @resource
  end
end
