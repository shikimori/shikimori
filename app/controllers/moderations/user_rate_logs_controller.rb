class Moderations::UserRateLogsController < ModerationsController
  def show
    @resource = UserRateLog.find params[:id]

    og noindex: true
    og page_title: i18n_t('page_title.show', id: @resource.id)
  end

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title.index')

    @page = (params[:page] || 1).to_i
    @limit = 30

    @collection = QueryObjectBase
      .new(UserRateLog.order(id: :desc).includes(:user, :target, :oauth_application))
      .paginate(@page, @limit)
  end
end
