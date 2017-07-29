# импортер аниме и манги в список пользователя
class UserRatesImporter
  COUNTERS = %i[episodes volumes chapters]

  ANIME_TYPE = 1
  MANGA_TYPE = 2

  def initialize user, klass
    @user = user
    @klass = klass
  end

  # импорт списка
  def import list_to_import, rewrite_existing
    # уже имеющееся у пользователя в списке
    rates = user_rates.each_with_object({}) { |v, memo| memo[v.target_id] = v }

    # то, что будет добавлено с нуля
    added = []
    # то, что будет обновлено
    updated = []
    # то, что не будет импортированно совсем
    not_imported = []

    list_to_import.each do |entry|
      update = false
      add = false

      rate = rates[entry[:target_id]]

      if entry[:target_id].nil? || entry[:status].nil?
        not_imported << (entry[:name] || entry[:target_id])
        next
      elsif rate.nil?
        rate = UserRate.new(
          user_id: @user.id,
          target_id: entry[:target_id],
          target_type: entry[:target_type]
        )
        add = true
      elsif rate && !rewrite_existing
        #not_imported << entry[:id]
        next
      else
        update = true
      end

      COUNTERS.each do |counter|
        rate[counter] = entry[counter] if entry.include? counter
      end

      rate.status = entry[:status].to_i
      rate.score = entry[:score].to_i
      rate.rewatches = entry[:rewatches].to_i
      text = entry[:text].gsub(%r{<br ?/?>}, "\n").strip if entry[:text]
      rate.text = text if text.present?

      # нельзя указать больше/меньше эпизодов/частей/томов для просмотренного,
      # чем имеется в аниме/манге
      COUNTERS.each do |counter|
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
          not_imported << (rate.target ? rate.target.name : rate.target_id)
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
