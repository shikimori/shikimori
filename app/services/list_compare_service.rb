class ListCompareService
  Dropped = UserRateStatus.get UserRateStatus::Dropped
  Planned = UserRateStatus.get UserRateStatus::Planned

  def self.fetch(user1, user2, params)
    new(user1, user2, params).fetch
  end

  def initialize(user1, user2, params)
    @user1 = user1
    @user2 = user2
    @params = params
    @klass = params[:klass]

    @compatibility = CompatibilityService.new(@user1, @user2, @klass)
  end

  def fetch
    # список первого пользователя
    user1_rates = user_rates @user1
    user1_ids_unsorted = user1_rates.to_a.sort_by {|k,v| -1 * (v.score || 0) }.map {|k,v| k }
    user1_norm_rates = @compatibility.user_rates @user1

    # список второго пользователя
    user2_rates = user_rates @user2
    user2_ids_unsorted = user2_rates.to_a.sort_by {|k,v| -1 * (v.score || 0) }.map {|k,v| k }
    user2_norm_rates = @compatibility.user_rates @user2

    # все аниме/манга, участвующие в сравнении
    data = fetch_entries((user1_ids_unsorted + user2_ids_unsorted).uniq)
    sorted_ids = data.map(&:id)
    entries = data.each_with_object({}) {|v,memo| memo[v.id] = v }

    # сортировка
    user1_ids = @params[:order] == 'user_1' ? user1_ids_unsorted & sorted_ids : sorted_ids & user1_ids_unsorted
    user2_ids = @params[:order] == 'user_2' ? user2_ids_unsorted & sorted_ids : sorted_ids & user2_ids_unsorted

    # финальные данные
    [
      # пересечения списков
      [:both, @params[:order] == 'user_2' ?
                user2_ids & user1_ids :
                user1_ids & user2_ids],
      # только первый пользователь
      [:user_1_only, (@params[:order] == 'user_2' || @params[:order] == 'user_1') ?
                       user1_ids_unsorted & sorted_ids & (user1_ids - user2_ids) :
                       user1_ids - user2_ids],
      # только второй пользователь
      [:user_2_only, (@params[:order] == 'user_2' || @params[:order] == 'user_1') ?
                       user2_ids_unsorted & sorted_ids & (user2_ids - user1_ids) :
                       user2_ids - user1_ids],
    ].map do |(key,ids)|
      [
        key,
        group_by_key(key),
        ids.map do |id|
          build_entry id, user1_rates, user1_norm_rates, user2_rates, user2_norm_rates, entries
        end
      ]
    end
  end

private
  def user_rates(user)
    rates = user.send("#{@klass.name.downcase}_rates")

    rates.each_with_object({}) do |v,memo|
      memo[v.target_id] = v
      v[:rate] = !v.score || v.score == 0 ? nil : v.score
      v[:rate] = nil if v.status == Dropped
    end
  end

  def group_by_key(key)
    case key
      when :both
        'В обоих списках'

      when :user_1_only
        "Только в списке #{@user1.nickname}"

      when :user_2_only
        "Только в списке #{@user2.nickname}"
    end
  end

  def fetch_entries(ids)
    AniMangaQuery.new(@klass, @params, @user1).fetch
        .where("#{@klass.table_name}.id in (?)", ids)
        .select(["#{@klass.table_name}.id", "#{@klass.table_name}.name", "#{@klass.table_name}.russian"])
        .all
  end

  def build_entry(id, user1_rates, user1_norm_rates, user2_rates, user2_norm_rates, entries)
    entry = {
      name: UserPresenter.localized_name(entries[id], @user1),
      entry: entries[id],
      rate_1: user1_rates.include?(id) ? user1_rates[id][:rate] : nil,
      rate_2: user2_rates.include?(id) ? user2_rates[id][:rate] : nil,

      #norm_rate_1_: user1_norm_rates.include?(id) ?
          #user1_norm_rates[id].round(2) :
          #nil,
      norm_rate_1: user1_norm_rates.include?(id) ?
          ((user1_norm_rates[id] >= 0 ? 1.0 : -1.0) * Math.sqrt(30.0 * user1_norm_rates[id].abs)).round(2) :
          nil,
      #norm_rate_2_: user2_norm_rates.include?(id) ?
          #user2_norm_rates[id].round(2) :
          #nil,
      norm_rate_2: user2_norm_rates.include?(id) ?
          ((user2_norm_rates[id] >= 0 ? 1.0 : -1.0) * Math.sqrt(30.0 * user2_norm_rates[id].abs)).round(2) :
          nil,

      url: "/#{@klass.name.downcase.pluralize}/#{id}"
    }

    entry[:diff] = if entry[:rate_1] && entry[:rate_2] && entry[:norm_rate_1] && entry[:norm_rate_2]
      (entry[:norm_rate_1] - entry[:norm_rate_2]).abs.round(2)
    else
      nil
    end

    entry[:rate_1_title] = if entry[:rate_1] && user1_rates[id].status == Dropped
      '<span class="notice">брошено</span>'
    elsif !entry[:rate_1] && user1_rates.include?(id) && user1_rates[id].status == Planned
      '<span class="notice">в планах</span>'
    else
      #"#{entry[:rate_1] || '&ndash;'}&nbsp;&nbsp;|&nbsp;&nbsp;#{entry[:norm_rate_1] if entry[:norm_rate_1]}"
      entry[:rate_1] || '&ndash;'
    end

    entry[:rate_2_title] = if entry[:rate_2] && user2_rates[id].status == Dropped
      '<span class="notice">брошено</span>'
    elsif !entry[:rate_2] && user2_rates.include?(id) && user2_rates[id].status == Planned
      '<span class="notice">в планах</span>'
    else
      #"#{entry[:rate_2] || '&ndash;'}&nbsp;&nbsp;|&nbsp;&nbsp;#{entry[:norm_rate_2] if entry[:norm_rate_2]}"
      entry[:rate_2] || '&ndash;'
    end

    if entry[:diff]
      entry[:variety] = if entry[:diff] <= 0.7
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
end
