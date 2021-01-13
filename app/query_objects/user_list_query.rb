class UserListQuery
  method_object %i[klass! user! params!]

  def call
    user_rates
      .each_with_object(statuses) do |user_rate, memo|
        memo[user_rate.status.to_sym] ||= []
        memo[user_rate.status.to_sym] << UserRates::StructEntry.create(user_rate)
      end
      .delete_if { |_status, user_rates| user_rates.none? }
  end

private

  def user_rates
    # commented until https://github.com/rails/rails/issues/12953 is fixed
    # user_rates.merge(AniMangaQuery.new(@klass, @params, @user).fetch.except(:order))
    @user
      .send("#{list_type}_rates")
      .where(target_id: db_entries.scope.select('id'))
      .includes(list_type.to_sym)
      .references(list_type.to_sym)
      .order(
        Animes::Filters::OrderBy.arel_sql(
          terms: [:rate_status, params_order],
          scope: @klass
        )
      )
  end

  def db_entries
    Animes::Query.fetch(
      scope: @klass,
      params: params_with_mylist,
      user: @user,
      is_apply_excludes: false,
      is_apply_order: false
    )
  end

  def statuses
    @statuses ||= UserRate
      .statuses
      .keys
      .each_with_object({}) { |status, memo| memo[status.to_sym] = [] }
  end

  def list_type
    @klass.name.downcase
  end

  def anime?
    list_type == 'anime'
  end

  def params_with_mylist
    if @params[:statuses].blank?
      @params.merge(statuses: statuses.keys.join(','))
    else
      @params
    end
  end

  def params_order
    term = @params[:order].to_sym

    if @klass == Anime && %i[volumes chapters].include?(term)
      :episodes
    elsif @klass != Anime && term == :episodes
      :chapters
    else
      term
    end
  end
end
