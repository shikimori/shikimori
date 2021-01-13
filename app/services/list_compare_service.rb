# TODO: refactor
class ListCompareService
  include Translation

  method_object %i[user_1! user_2! params!]

  URL_PREFIX = {
    'Anime' => 'animes',
    'Manga' => 'mangas',
    'Ranobe' => 'ranobe'
  }

  def call
    # список первого пользователя
    user_1_rates = user_rates @user_1
    user_1_ids_unsorted = user_1_rates
      .to_a
      .sort_by { |_k, v| -1 * (v.score || 0) }
      .map { |k, _v| k }
    user_1_norm_rates = compatibility.user_rates @user_1, nil

    # список второго пользователя
    user_2_rates = user_rates @user_2
    user_2_ids_unsorted = user_2_rates
      .to_a
      .sort_by { |_k, v| -1 * (v.score || 0) }
      .map { |k, _v| k }
    user_2_norm_rates = compatibility.user_rates @user_2, nil

    # все аниме/манга, участвующие в сравнении
    data = fetch_entries((user_1_ids_unsorted + user_2_ids_unsorted).uniq)
    sorted_ids = data.map(&:id)
    entries = data.each_with_object({}) { |v, memo| memo[v.id] = v }

    # sorting
    user_1_ids = @params[:order] == 'user_1' ?
      user_1_ids_unsorted & sorted_ids :
      sorted_ids & user_1_ids_unsorted
    user_2_ids = @params[:order] == 'user_2' ?
      user_2_ids_unsorted & sorted_ids :
      sorted_ids & user_2_ids_unsorted

    # финальные данные
    [
      # пересечения списков
      [
        :both,
        @params[:order] == 'user_2' ?
          user_2_ids & user_1_ids :
          user_1_ids & user_2_ids
      ],
      # только первый пользователь
      [
        :user_1_only,
        %w[user_2 user_1].include?(@params[:order]) ?
          user_1_ids_unsorted & sorted_ids & (user_1_ids - user_2_ids) :
          user_1_ids - user_2_ids
      ],
      # только второй пользователь
      [
        :user_2_only,
        %w[user_2 user_1].include?(@params[:order]) ?
          user_2_ids_unsorted & sorted_ids & (user_2_ids - user_1_ids) :
          user_2_ids - user_1_ids
      ]
    ].map do |(key, ids)|
      [
        key,
        group_by_key(key),
        ids.map do |id|
          build_entry(
            id,
            user_1_rates,
            user_1_norm_rates,
            user_2_rates,
            user_2_norm_rates,
            entries
          )
        end
      ]
    end
  end

private

  def user_rates(user)
    rates = user.send("#{klass.name.downcase}_rates")

    rates.each_with_object({}) do |v, memo|
      memo[v.target_id] = v
      v.score = !v.score || v.score == 0 ? nil : v.score
      v.score = nil if v.dropped?
    end
  end

  def group_by_key(key)
    case key
      when :both
        i18n_t 'group_by_key.both'

      when :user_1_only
        i18n_t 'group_by_key.user_only', nickname: @user_1.nickname

      when :user_2_only
        i18n_t 'group_by_key.user_only', nickname: @user_2.nickname
    end
  end

  def fetch_entries(ids)
    Animes::Query
      .fetch(scope: klass, params: @params, user: @user_1)
      .where("#{klass.table_name}.id in (?)", ids)
      .select(
        [
          "#{klass.table_name}.id",
          "#{klass.table_name}.name",
          "#{klass.table_name}.russian"
        ]
      )
      .all
  end

  def build_entry(
    id,
    user_1_rates,
    user_1_norm_rates,
    user_2_rates,
    user_2_norm_rates,
    entries
  )
    entry = {
      name: UsersHelper.localized_name(entries[id], @user_1),
      entry: entries[id],
      rate_1: user_1_rates.include?(id) ? user_1_rates[id].score : nil,
      rate_2: user_2_rates.include?(id) ? user_2_rates[id].score : nil,

      # norm_rate_1_: user_1_norm_rates.include?(id) ?
          # user_1_norm_rates[id].round(2) :
          # nil,
      norm_rate_1: user_1_norm_rates.include?(id) ?
        (
          (user_1_norm_rates[id] >= 0 ? 1.0 : -1.0) *
            Math.sqrt(30.0 * user_1_norm_rates[id].abs)
        ).round(2) :
        nil,
      # norm_rate_2_: user_2_norm_rates.include?(id) ?
          # user_2_norm_rates[id].round(2) :
          # nil,
      norm_rate_2: user_2_norm_rates.include?(id) ?
        (
          (user_2_norm_rates[id] >= 0 ? 1.0 : -1.0) *
            Math.sqrt(30.0 * user_2_norm_rates[id].abs)
        ).round(2) :
        nil,

      url: "/#{URL_PREFIX[klass.name]}/" +
        CopyrightedIds.instance.change(id, klass.name.downcase)
    }

    entry[:diff] =
      if entry[:rate_1] && entry[:rate_2] &&
          entry[:norm_rate_1] && entry[:norm_rate_2]
        (entry[:norm_rate_1] - entry[:norm_rate_2]).abs.round(2)
      end

    entry[:rate_1_title] =
      if entry[:rate_1] && user_1_rates[id].dropped?
        "<span class='notice'>#{i18n_t 'user_rate_status.dropped'}</span>"
      elsif !entry[:rate_1] && user_1_rates.include?(id) && user_1_rates[id].planned?
        "<span class='notice'>#{i18n_t 'user_rate_status.planned'}</span>"
      else
        # "#{entry[:rate_1] || '&ndash;'}&nbsp;&nbsp;|&nbsp;&nbsp;#{entry[:norm_rate_1] if entry[:norm_rate_1]}"
        entry[:rate_1] || '&ndash;'
      end

    entry[:rate_2_title] =
      if entry[:rate_2] && user_2_rates[id].dropped?
        "<span class='notice'>#{i18n_t 'user_rate_status.dropped'}</span>"
      elsif !entry[:rate_2] && user_2_rates.include?(id) && user_2_rates[id].planned?
        "<span class='notice'>#{i18n_t 'user_rate_status.planned'}</span>"
      else
        # "#{entry[:rate_2] || '&ndash;'}&nbsp;&nbsp;|&nbsp;&nbsp;#{entry[:norm_rate_2] if entry[:norm_rate_2]}"
        entry[:rate_2] || '&ndash;'
      end

    if entry[:diff]
      entry[:variety] =
        if entry[:diff] <= 0.7
          'exact-same'
        elsif entry[:diff] < 2
          'almost-same'
        elsif entry[:diff] < 3
          'slightly-difr'
        else
          'abslt-difr'
      end
    end

    entry
  end

  def klass
    @params[:klass]
  end

  def compatibility
    @compatibility ||= CompatibilityService.new(@user_1, @user_2, klass)
  end
end
