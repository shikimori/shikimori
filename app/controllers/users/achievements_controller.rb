class Users::AchievementsController < ProfilesController
  before_action :additional_breadcrumbs, except: [:index]
  before_action do
    og page_title: i18n_t('achievements')
    @view = Profiles::AchievementsView.new @user
  end

  def index
  end

  def franchise
    og page_title: t('achievements.group.franchise')
  end

  def author
    og page_title: t('achievements.group.author')
  end

private

  def additional_breadcrumbs
    @back_url = profile_achievements_url(@resource)
    breadcrumb i18n_t('achievements'), @back_url
  end
end
