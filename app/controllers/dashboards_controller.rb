class DashboardsController < ShikimoriController
  def show
    og type: 'website'
    og page_title: i18n_t('h1_header')

    @dashboard_view = DashboardView.new
  end
end
