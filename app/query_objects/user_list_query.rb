class UserListQuery
  def initialize klass, user, params
    @klass = klass
    @user = user

    @params = params.merge klass: @klass
    raise 'must show hentai in profile' # @params = params.merge klass: @klass, userlist: true
  end

  def fetch
    user_rates
      .each_with_object(statuses) do |rate, memo|
        memo[rate.status.to_sym] ||= []
        memo[rate.status.to_sym] << rate.decorate
      end
      .delete_if { |_status, rates| rates.none? }
  end

private

  def user_rates
    # commented until https://github.com/rails/rails/issues/12953 is fixed
    # user_rates.merge(AniMangaQuery.new(@klass, @params, @user).fetch.except(:order))
    @user
      .send("#{list_type}_rates")
      .includes(list_type.to_sym)
      .references(list_type.to_sym)
      .where("#{@klass.table_name}.id in (?)", target_ids)
      .order(
        Arel.sql(
          Animes::Filters::OrderBy.terms_sql([:rate_status, @params[:order].to_sym], @klass)
        )
      )
  end

  def target_ids
    @target_ids ||= AniMangaQuery
      .new(@klass, @params, @user)
      .fetch
      .except(:order)
      .pluck(:id)
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
end
