class Users::AchievementsController < ProfilesController
  before_action :additional_breadcrumbs, except: [:index]
  before_action { og page_title: i18n_t('achievements') }
  before_action :check_access

  def index
    @view = Profiles::AchievementsView.new(@user)
  end

  def franchise
    og page_title: t('achievements.group.franchise')

    @view = Profiles::AchievementsView.new(@user)
  end

private

  def check_access
    return if Rails.env.development?
    return if current_user&.admin?

    raise ActiveRecord::RecordNotFound
  end

  def additional_breadcrumbs
    @back_url = profile_achievements_url(@resource)
    breadcrumb i18n_t('achievements'), @back_url
  end
end
