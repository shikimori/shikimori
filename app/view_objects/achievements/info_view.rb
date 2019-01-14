class Achievements::InfoView
  include Draper::ViewHelpers
  vattr_initialize :achievements

  delegate :animes_scope, :neko_id, to: :achievement

  CACHE_VERSION = :v5

  def achievement
    achievements.first
  end

  def user_achievement
    @user_achievement ||= achievements.reverse.find { |v| v.is_a? Achievement } ||
      achievement
  end

  def franchise_percent
    @franchise_percent ||= user_achievement.franchise_percent h.current_user
  end

  def overall_percent
    @overall_percent ||= user_achievement.overall_percent h.current_user
  end

  def animes_count
    @animes_count ||= achievement.animes_count
  end

  def show_animes?
    (animes_count && animes_count < 500) ||
      achievement.rule.dig(:filters, 'anime_ids') ||
      achievement.rule.dig(:filters, 'franchise') ||
      h.params[:animes]
  end

  def filters
    achievement.rule[:filters]
  end

  def extended_cache_key
    [
      h.current_user&.achievements&.cache_key,
      (h.current_user&.anime_rates&.cache_key unless filters),
      neko_id,
      CACHE_VERSION
    ]
  end

  def user_progress
    if user_achievement.is_a? Achievement
      user_achievement.progress
    else
      (overall_percent * 100.0 / achievement.threshold_percent(animes_count)).ceil(2)
    end
  end
end
