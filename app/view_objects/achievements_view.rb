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
      .sort_by { |rule| [rule.level.zero? ? 1 : 0] + franchise_sort_criteria(rule) }
  end

  def franchise_achievements_count
    franchise_achievements.select { |rule| rule.level == 1 }.size
  end

  def all_franchise_achievements
    NekoRepository
      .instance
      .select(&:franchise?)
      .select { |rule| rule.level.zero? }
      .sort_by { |rule| franchise_sort_criteria rule }
  end

  def missing_franchise_achievements
    all_franchise_achievements
      .reject { |rule| franchise_achievements.map(&:neko_id).include? rule.neko_id }
      .select { |rule| rule.level.zero? }
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

  def franchise_sort_criteria rule
    if h.cookies[:franchises_order] == 'alphabet'
      rule_name = rule.title(h.current_user, h.ru_host?).downcase.gsub(/[^[:alnum:]]+/, '')

      [
        Localization::RussianNamesPolicy.call(h.current_user) ?
          Translit.convert(rule_name, :russian) :
          rule_name,
        rule.level
      ]
    else
      rule.sort_criteria
    end
  end
end
