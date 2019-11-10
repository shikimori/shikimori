class Profiles::AchievementsView < ViewObjectBase
  pattr_initialize :user

  STUDIOS_LINE_COUNT = 4
  ACHIEVEMENTS_PER_ROW = 4

  instance_cache :user_achievements, :common_achievements, :genre_achievements,
    :franchise_achievements, :franchise_achievements_size,
    :all_franchise_achievements, :missing_franchise_achievements,
    :author_achievements, :author_achievements_size,
    :all_author_achievements, :missing_author_achievements

  def common_achievements
    user_achievements.select(&:common?)
  end

  def genre_achievements
    user_achievements.select(&:genre?)
  end

  def franchise_achievements
    type_achievements :franchise
  end

  def franchise_achievements_size
    type_achievements_size :franchise
  end

  def all_franchise_achievements
    all_type_achievements :franchise
  end

  def missing_franchise_achievements
    all_franchise_achievements
      .reject { |rule| franchise_achievements.map(&:neko_id).include? rule.neko_id }
      .select { |rule| rule.level.zero? }
      .take(
        missing_franchise_achievements_size(
          genre_achievements.size,
          franchise_achievements.size
        )
      )
  end

  def author_achievements
    type_achievements :author
  end

  def author_achievements_size
    type_achievements_size :author
  end

  def all_author_achievements
    all_type_achievements :author
  end

  def missing_author_achievements
    all_author_achievements
      .reject { |rule| author_achievements.map(&:neko_id).include? rule.neko_id }
  end

private

  def user_achievements
    @user.achievements
      .sort_by(&:sort_criteria)
      .group_by(&:neko_id)
      .map(&:second)
      .map(&:last)
  end

  def missing_franchise_achievements_size(
    genre_achievements_count,
    franchise_achievements_size
  )
    count = [
      (genre_achievements_count * 6.88).round -
        STUDIOS_LINE_COUNT -
        franchise_achievements_size,
      0
    ].max

    missing_row_count = ACHIEVEMENTS_PER_ROW -
      (franchise_achievements_size + count) % ACHIEVEMENTS_PER_ROW

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

  def type_achievements type
    user_achievements
      .select { |v| v.send :"#{type}?" }
      .sort_by { |rule| [rule.level.zero? ? 1 : 0] + franchise_sort_criteria(rule) }
  end

  def type_achievements_size type
    type_achievements(type).select { |rule| rule.level == 1 }.size
  end

  def all_type_achievements type
    NekoRepository
      .instance
      .select { |v| v.send :"#{type}?" }
      .select { |rule| type != :franchise || rule.level.zero? }
      .sort_by { |rule| franchise_sort_criteria rule }
  end
end
