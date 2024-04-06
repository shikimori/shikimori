class Moderations::PostersController < ModerationsController
  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')
  end
end
