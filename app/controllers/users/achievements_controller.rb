class Users::AchievementsController < ProfilesController
  before_action :additional_breadcrumbs, except: [:index]
  before_action { og page_title: i18n_t('achievements') }

  def index
    unless current_user&.admin? || @user.nickname == 'test2' ||
        Rails.env.development?
      raise ActiveRecord::RecordNotFound
    end

    collection = @user.achievements
      .sort_by(&:sort_criteria)
      .group_by(&:neko_id)
      .map(&:second)
      .map(&:last)

    @collections = {
      common: collection.select(&:common?),
      genre: collection.select(&:genre?),
      franchise: collection.select(&:franchise?)
    }
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
