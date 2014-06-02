# импортер аниме и манги в список пользователя
class UserRatesImporter
  Counters = [:episodes, :volumes, :chapters]

  def initialize user, klass
    @user = user
    @klass = klass
  end

  # импорт списка
  # третьим параметром ожидается массив хешей с ключами
  #   :id, :score, :status, :episodes, :chapters, :volumes
  # :status должен быть циферкой, не словом
  def import list_to_import, rewrite_existed
    # уже имеющееся у пользователя в списке
    rates = user_rates.each_with_object({}) {|v,memo| memo[v.target_id] = v }

    # то, что будет добавлено с нуля
    added = []
    # то, что будет обновлено
    updated = []
    # то, что не будет импортированно совсем
    not_imported = []

    list_to_import.each do |entry|
      update = false
      add = false

      rate = rates[entry[:id]]

      if entry[:id].nil? || entry[:status].nil?
        not_imported << entry[:id]
        next
      elsif rate.nil?
        rate = UserRate.new user_id: @user.id, target_id: entry[:id], target_type: @klass.name
        add = true
      elsif rate && !rewrite_existed
        #not_imported << entry[:id]
        next
      else
        update = true
      end

      Counters.each do |counter|
        rate[counter] = entry[counter] if entry.include? counter
      end

      rate.status = entry[:status].to_i
      rate.score = entry[:score].to_i
      rate.rewatches = entry[:rewatches].to_i
      rate.text = entry[:text] if entry[:text]

      # нельзя указать больше/меньше эпизодов,частей,томов для просмотренного, чем имеется в аниме/манге
      Counters.each do |counter|
        target = rate.target

        if rate.completed?
          rate[counter] = target[counter] if target.respond_to?(counter) && target[counter] > 0 && rate[counter] < target[counter]
        end
        rate[counter] = target[counter] if target.respond_to?(counter) && target[counter] > 0 && rate[counter] > target[counter]
      end

      if rate.changes.any?
        if rate.save
          updated << rate.target_id if update
          added << rate.target_id if add
        else
          not_imported << rate.target_id
        end
      end
    end

    [added, updated, not_imported]
  end

private
  def user_rates
    @user.send "#{@klass.name.downcase}_rates"
  end
end
