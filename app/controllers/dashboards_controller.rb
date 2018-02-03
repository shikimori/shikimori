class DashboardsController < ShikimoriController
  def show
    og type: 'website'
    og page_title: i18n_t('page_title')
    # og description: i18n_t('description')

    @dashboard_view = DashboardView.new
  end
end
