class DashboardsController < ShikimoriController
  def show
    page_title i18n_t('h1_header')
    @view = DashboardView.new
  end
end
