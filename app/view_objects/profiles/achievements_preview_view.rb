class Profiles::AchievementsPreviewView < ViewObjectBase
  vattr_initialize :user, :is_own_profile
  instance_cache :achievements_view

  delegate :franchise_achievements_size,
    :all_franchise_achievements,
    :author_achievements_size,
    :author_achievements,
    :all_author_achievements,
    to: :achievements_view

  def available?
    return false unless @user.preferences.achievements_in_profile?

    # return false if @user.cheat_bot? && !@is_own_profile

    achievements_view.franchise_achievements_size.positive? ||
      achievements_view.common_achievements.size.positive? ||
      achievements_view.genre_achievements.size.positive?
  end

  def common_achievements
    achievements_view.common_achievements.shuffle.take(4).sort_by(&:sort_criteria)
  end

  def genre_achievements
    achievements_view.genre_achievements.shuffle.take(4).sort_by(&:sort_criteria)
  end

  def franchise_achievements
    all_franchise_achievements = achievements_view.user_achievements.select(&:franchise?)

    sort_combined_achievements(
      level_achievements(all_franchise_achievements, 1) +
        level_achievements(all_franchise_achievements, 0)
    ).take(12)
  end

  def author_achievements
    completed_authors = level_achievements all_author_achievements, 1

    return [] if completed_authors.none?

    sort_combined_achievements(
      completed_authors +
        level_achievements(all_author_achievements, 0)
    ).take(4)
  end

private

  def achievements_view
    Profiles::AchievementsView.new @user
  end

  def level_achievements achievements, level
    achievements
      .select { |v| v.level == level }
      .shuffle
  end

  def sort_combined_achievements achievements
    achievements.sort_by do |rule|
      [rule.level.zero? ? 1 : 0, -rule.progress]
    end
  end
end
