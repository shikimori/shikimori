# class reload 'anonses' and 'ongoings'
# in user_rate assication of provided libary
class UserRates::RefreshIrrelevant < ServiceObjectBase
  # library is a hash with
  # key = user_rate.status
  # value = user_rates of this status
  pattr_initialize :library, :klass

  def call
    reload irrelevants
  end

private

  def irrelevants
    @library.each_with_object({}) do |(status, list), memo|
      list.user_rates.each_with_index do |user_rate, index|
        next unless user_rate.target.anons? || user_rate.target.ongoing?
        memo[user_rate.target_id] = [status, index]
      end
    end
  end

  def reload irrelevants
    @klass
      .where(id: irrelevants.keys)
      .decorate
      .each do |entry|
        status, index = irrelevants[entry.id]
        assign_entry status, index, entry
      end
  end

  def assign_entry status, index, entry
    association_name = @klass.name.downcase.to_sym
    user_rate = @library[status].user_rates[index]
    association_cache = (user_rate.decorated? ? user_rate.object : user_rate)
      .instance_variable_get('@association_cache')

    association_cache[association_name].target = entry
  end
end
