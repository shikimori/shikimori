class Profiles::AchievementsView < ViewObjectBase
  pattr_initialize :user

  STUDIOS_LINE_COUNT = 4
  ACHIEVEMENTS_PER_ROW = 4

  instance_cache :user_achievements,
    :common_achievements, :common_achievements_size,
    :all_common_achievements, :all_common_achievements_size,
    :genre_achievements, :genre_achievements_size,
    :all_genre_achievements, :all_genre_achievements_size,
    :franchise_achievements, :franchise_achievements_size,
    :all_franchise_achievements, :missing_franchise_achievements,
    :author_achievements, :author_achievements_size,
    :all_author_achievements

  %i[common genre franchise author].each do |type|
    define_method :"#{type}_achievements" do
      type_achievements type
    end

    define_method :"#{type}_achievements_size" do
      type_achievements_size type
    end

    define_method :"all_#{type}_achievements" do
      all_type_achievements type
    end

    define_method :"all_#{type}_achievements_size" do
      all_type_achievements(type).size
    end
  end

  def missing_franchise_achievements
    all_franchise_achievements
      .reject { |rule| rule.is_a? Achievement }
      .take(
        missing_franchise_achievements_size(
          genre_achievements.size,
          franchise_achievements.size
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
      ((franchise_achievements_size + count) % ACHIEVEMENTS_PER_ROW)

    count + (missing_row_count == ACHIEVEMENTS_PER_ROW ? 0 : missing_row_count)
  end

  def sort_criteria_by_type rule, type # rubocop:disable AbcSize
    if h.cookies[:"#{type}s_order"] == 'alphabet'
      rule_name = rule.title(h.current_user, h.ru_host?).downcase.gsub(/[^[:alnum:]]+/, '')
      [
        Localization::RussianNamesPolicy.call(h.current_user) ?
          Translit.convert(rule_name, :russian) :
          rule_name,
        rule.level
      ]
    elsif h.cookies[:"#{type}s_order"] == 'progress'
      [-rule.progress] + rule.sort_criteria
    else
      rule.sort_criteria
    end
  end

  def type_achievements type
    user_achievements
      .select { |rule| rule.send :"#{type}?" }
      .sort_by { |rule| [rule.level.zero? ? 1 : 0] + sort_criteria_by_type(rule, type) }
  end

  def type_achievements_size type
    type_achievements(type).count { |rule| rule.level.positive? }
  end

  def all_type_achievements type
    user_type_achievements = type_achievements type

    NekoRepository
      .instance
      .select { |rule| rule.send :"#{type}?" }
      .select { |rule| type != :franchise || rule.level.zero? }
      .group_by(&:neko_id)
      .map do |neko_id, rules|
        user_type_achievements
          .select { |rule| rule.neko_id == neko_id }
          .max_by(&:level) || rules.min_by(&:level)
      end
      .sort_by { |rule| sort_criteria_by_type(rule, type) }
  end
end
