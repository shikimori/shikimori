class Moderations::UserRateLogsController < ModerationsController
  load_and_authorize_resource only: %i[show]

  LIMIT = 45

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title.index')

    @collection = QueryObjectBase
      .new(UserRateLog.order(id: :desc).includes(:user, :target, :oauth_application))
      .paginate(@page, LIMIT)
  end

  def show
    og noindex: true
    og page_title: i18n_t('page_title.show', id: @resource.id)
    breadcrumb i18n_t('page_title.index'), moderations_user_rate_logs_url
  end
end
