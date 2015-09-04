class ModerationsController < ShikimoriController
  before_action :authenticate_user!

  def show
    page_title t('application.top_menu.shikimori.moderations_content')
  end
end
