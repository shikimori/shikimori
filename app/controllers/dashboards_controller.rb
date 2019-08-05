class DashboardsController < ShikimoriController
  before_action do
    @dashboard_view = DashboardView.new
  end

  def show
    og type: 'website'
    og page_title: i18n_t('page_title')
    og description: i18n_t('description')
    og image: "#{Shikimori::PROTOCOL}://#{Shikimori::DOMAIN}" \
      '/favicons/opera-icon-228x228.png'
  end

  def dynamic
  end
end
