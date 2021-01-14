# class reloads 'anonses' and 'ongoings'
# in user_rate assication of provided libary
class UserRates::RefreshIrrelevant
  # library is a hash with
  # key = user_rate.status
  # value = user_rates of this status
  method_object :library, :klass

  def call
    reload irrelevants
  end

private

  def irrelevants
    @library.each_with_object({}) do |(status, list), memo|
      list.user_rates.each_with_index do |user_rate, index|
        next unless user_rate.target_is_anons || user_rate.target_is_ongoing

        memo[user_rate.target_id] = [status, index]
      end
    end
  end

  def reload irrelevants
    @klass
      .where(id: irrelevants.keys)
      .each do |entry|
        status, index = irrelevants[entry.id]
        assign_entry status, index, entry
      end
  end

  def assign_entry status, index, entry
    user_rate = @library[status].user_rates[index]

    if entry.respond_to? :episodes
      user_rate.target_episodes = entry.episodes
      user_rate.target_episodes_aired = entry.episodes_aired
    end
    user_rate.target_is_anons = entry.anons?
    user_rate.target_is_ongoing = entry.ongoing?
  end
end
