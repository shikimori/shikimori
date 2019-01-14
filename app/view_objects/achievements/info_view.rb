class Achievements::InfoView
  include Draper::ViewHelpers
  vattr_initialize :achievements

  def achievement
    achievements.first
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
end
