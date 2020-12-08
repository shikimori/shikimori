class Achievements::InfoView
  include Draper::ViewHelpers
  vattr_initialize :achievements

  delegate :animes_scope, :neko_id, :anime_rates, to: :achievement

  CACHE_VERSION = :v5

  def achievement
    achievements.first
  end

  def author
    @author ||= Person
      .find(achievement.rule.dig(:generator, 'person_id'))
      .decorate
  end

  def user_achievement
    @user_achievement ||= achievements.reverse.find { |v| v.is_a? Achievement } ||
      achievement
  end

  def franchise_percent
    @franchise_percent ||= user_achievement.franchise_percent h.current_user
  end

  def overall_percent
    @overall_percent ||= user_achievement.overall_percent h.current_user, animes_count
  end

  def animes_count
    @animes_count ||= achievement.animes_count
  end

  def list_size
    return 0 unless h.current_user

    anime_rates(h.current_user, false).count
  end

  def show_animes?
    (animes_count && animes_count < 500) ||
      achievement.rule.dig(:filters, 'anime_ids') ||
      achievement.rule.dig(:filters, 'franchise') ||
      h.params[:animes]
  end

  def filters
    return unless achievement.rule[:filters]

    {
      **achievement.rule[:filters].symbolize_keys,
      ignore_latest_ids: achievement.rule[:ignore_latest_ids],
      not_ignored_ids: achievement.rule[:not_ignored_ids]
    }.compact
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
      count = filters ? animes_count : list_size
      (overall_percent * 100.0 / achievement.threshold_percent(count)).ceil(2)
    end
  end
end
