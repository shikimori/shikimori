class Recommendations::ExcludedIds
  method_object :user, :type

  Types = Types::Strict::Symbol
    .constructor { |v| v.downcase.to_sym }
    .enum(:anime, :manga)

  def call
    @user
      .send("#{Types[@type]}_rates")
      .includes(Types[@type])
      .each_with_object([]) do |user_rate, memo|
        memo.push user_rate.target_id unless user_rate.planned?
      end
      .sort
  end
end
