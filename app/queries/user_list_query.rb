class UserListQuery
  def initialize klass, user, params
    @klass = klass
    @user = user

    @params = params.clone.merge(klass: @klass)
  end

  def fetch
    user_rates
      .merge(AniMangaQuery.new(@klass, @params, @user).fetch.except(:order))
      .order("user_rates.status, #{AniMangaQuery.order_sql order, @klass}")
      .each_with_object({}) do |v,memo|
        memo[v.status.to_sym] ||= []
        memo[v.status.to_sym] << v.decorate
      end
  end

private
  def user_rates
    @user.send("#{list_type}_rates")
      .includes(list_type.to_sym)
      .references(list_type.to_sym)
  end

  def list_type
    @klass.name.downcase
  end

  def order
    @params[:order]
  end

  def anime?
    list_type == 'anime'
  end
end
