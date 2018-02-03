class Users::AchievementsController < ProfilesController
  before_action :additional_breadcrumbs, except: [:index]
  before_action { og page_title: i18n_i('title') }

  def index
    unless current_user&.admin? || @user.nickname == 'test2'
      raise ActiveRecord::RecordNotFound
    end
  end

  def franchise
    og page_title: 'Франшизы'
  end

private

  def additional_breadcrumbs
    @back_url = profile_achievements_url(@resource)
    breadcrumb i18n_i('title'), @back_url
  end
end
