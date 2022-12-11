class Moderations::ChangelogsController < ModerationsController
  def index
    og page_title: i18n_t('page_title')
  end
end
