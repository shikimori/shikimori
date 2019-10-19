class DashboardsController < ShikimoriController
  def show
    og type: 'website'
    og page_title: i18n_t('page_title')
    og description: i18n_t('description')
    og image: "#{Shikimori::PROTOCOL}://#{Shikimori::DOMAIN}" \
      '/favicons/opera-icon-228x228.png'

    if current_user&.preferences&.dashboard_type_new?
      @view = DashboardViewV2.new
      render :show_v2
    else
      @view = DashboardView.new
      render :show
    end
  end

  def dynamic
    @view = DashboardView.new
  end
end
