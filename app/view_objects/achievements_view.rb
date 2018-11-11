class AchievementsView < ViewObjectBase
  pattr_initialize :user

  STUDIOS_LINE_COUNT = 4
  ACHIEVEMENTS_PER_ROW = 4

  instance_cache :user_achievements, :common_achievements, :genre_achievements,
    :franchise_achievements,
    :all_franchise_achievements, :missing_franchise_achievements

  def common_achievements
    user_achievements.select(&:common?)
  end

  def genre_achievements
    user_achievements.select(&:genre?)
  end

  def franchise_achievements
    user_achievements
      .select(&:franchise?)
      .sort_by { |v| [v.level.zero? ? 1 : 0] + v.sort_criteria }
  end

  def franchise_achievements_count
    franchise_achievements.select { |v| v.level == 1 }.size
  end

  def all_franchise_achievements
    NekoRepository.instance.select(&:franchise?)
  end

  def missing_franchise_achievements
    all_franchise_achievements
      .reject { |v| franchise_achievements.map(&:neko_id).include? v.neko_id }
      .select { |v| v.level.zero? }
      .take(
        missing_franchise_achievements_count(
          genre_achievements.size, franchise_achievements.size
        )
      )
  end

private

  def user_achievements
    @user.achievements
      .sort_by(&:sort_criteria)
      .group_by(&:neko_id)
      .map(&:second)
      .map(&:last)
  end

  def missing_franchise_achievements_count(
    genre_achievements_count,
    franchise_achievements_count
  )
    count = [
      (genre_achievements_count * 6.66).round -
        STUDIOS_LINE_COUNT -
        franchise_achievements_count,
      0
    ].max

    missing_row_count = ACHIEVEMENTS_PER_ROW -
      (franchise_achievements_count + count) % ACHIEVEMENTS_PER_ROW

    count + (missing_row_count == ACHIEVEMENTS_PER_ROW ? 0 : missing_row_count)
  end
end
