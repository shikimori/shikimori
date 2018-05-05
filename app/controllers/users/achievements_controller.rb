class Users::AchievementsController < ProfilesController
  before_action :additional_breadcrumbs, except: [:index]
  before_action { og page_title: i18n_t('achievements') }
  before_action :check_access

  FRAMCHISE_LIMIT = 60

  def index
    @common_achievements = user_achievements.select(&:common?)
    @genre_achievements = user_achievements.select(&:genre?)
    @franchise_achievements = user_achievements.select(&:franchise?)

    @missing_franchise_achievements = NekoRepository.instance
      .select(&:franchise?)
      .take(FRAMCHISE_LIMIT - @franchise_achievements.size)
  end

  def franchise
    og page_title: t('achievements.group.franchise')

    @all_franchise_achievements = NekoRepository.instance.select(&:franchise?)
    @user_franchise_achievements = user_achievements.select(&:franchise?)
  end

private

  def check_access
    return if Rails.env.development?
    return if current_user&.admin?
    return if current_user&.club_roles&.where(club_id: 315)&.any?
    return if @user.nickname == 'test2'

    raise ActiveRecord::RecordNotFound
  end

  def additional_breadcrumbs
    @back_url = profile_achievements_url(@resource)
    breadcrumb i18n_i('title'), @back_url
  end

  def user_achievements
    @user_achievements ||= @user.achievements
      .sort_by(&:sort_criteria)
      .group_by(&:neko_id)
      .map(&:second)
      .map(&:last)
  end
end
