class Moderations::UserRateLogsController < ModerationsController
  load_and_authorize_resource only: %i[show]

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title.index')

    @page = (params[:page] || 1).to_i
    @limit = 45

    @collection = QueryObjectBase
      .new(UserRateLog.order(id: :desc).includes(:user, :target, :oauth_application))
      .paginate(@page, @limit)
  end

  def show
    og noindex: true
    og page_title: i18n_t('page_title.show', id: @resource.id)
    breadcrumb i18n_t('page_title.index'), moderations_user_rate_logs_url
  end
end
