class Moderations::UserRateLogsController < ModerationsController
  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    @page = (params[:page] || 1).to_i
    @limit = 30

    @collection = QueryObjectBase
      .new(UserRateLog.order(id: :desc).includes(:user, :target, :oauth_application))
      .paginate(@page, @limit)
  end
end
