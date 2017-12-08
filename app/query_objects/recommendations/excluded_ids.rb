class Recommendations::ExcludedIds
  method_object :user, :klass

  Types = Types::Strict::Symbol
    .constructor { |v| v.downcase.to_sym }
    .enum(:anime, :manga)

  def call
    (
      in_list_except_planned(@user, @klass) +
        ignored_recommendations(@user, @klass)
    ).uniq.sort
  end

private

  def in_list_except_planned user, klass
    user
      .send("#{Types[klass.name]}_rates")
      .includes(Types[klass.name])
      .where.not(status: :planned)
      .pluck(:target_id)
  end

  def ignored_recommendations user, klass
    RecommendationIgnore
      .where(user_id: user.id, target_type: klass.name)
      .order(:id)
      .pluck(:target_id)
  end
end
