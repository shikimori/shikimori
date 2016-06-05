class DashboardsController < ShikimoriController
  def show
    page_title i18n_t('h1_header')
    @dashboard_view = DashboardView.new
  end
end
