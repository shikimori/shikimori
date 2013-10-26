# TODO: алгоритм очень неоптимален, когда пользователей станет слишком много, нужно будет
# переписать на разовую выборку всех оценок и полный проход по ним для выявляения совместимости
class SimilarUsersService
  ResultsLimit = 510

  def initialize(user, klass, threshold)
    @user = user
    @klass = klass
    @threshold = threshold
  end

  def fetch
    similarities
        .select {|k,v| v.present? }
        .sort_by {|k,v| -v}
        .take(ResultsLimit)
        .map(&:first)
  end

private
  def similarities
    users.each_with_object({}) do |v,memo|
      memo[v.id] = CompatibilityService.new(@user, v, @klass).fetch
    end
  end

  def users
    table_name = "#{@klass.name.downcase}_rates".to_sym

    User.joins(table_name)
        .where(table_name => { status: UserRateStatus.get(UserRateStatus::Completed) })
        .where { (user_rates.score.not_eq nil) & (user_rates.score > 0) }
        .where { id.not_eq my{@user.id} }
        .group('users.id')
        .having("count(*) > #{@threshold}")
  end
end
