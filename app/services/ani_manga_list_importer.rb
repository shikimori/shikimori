# импортер аниме и манги в профиль пользователя
module AniMangaListImporter
  Counters = [:episodes, :volumes, :chapters]

  # импорт списка
  # третьим параметром ожидается массив хешей с ключами :id, :score, :status, :episodes, :chapters, :volumes
  # :status должен быть словом, не циферкой
  def import user, klass, list_to_import, rewrite_existed
    # уже имеющееся у пользователя в списке
    rates = user.send("#{klass.name.downcase}_rates").each_with_object({}) do |entry,memo|
      memo[entry.target_id] = entry
    end

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

      if rate.nil?
        rate = UserRate.new user_id: user.id, target_id: entry[:id], target_type: klass.name
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

      rate.status = UserRateStatus.get entry[:status]
      rate.score = entry[:score].to_i

      # нельзя указать больше/меньше эпизодов,частей,томов для просмотренного, чем имеется в аниме/манге
      Counters.each do |counter|
        target = rate.target

        if rate.completed?
          rate[counter] = target[counter] if target.respond_to?(counter) && rate[counter] < target[counter]
        end
        rate[counter] = target[counter] if target.respond_to?(counter) && rate[counter] > target[counter]
      end

      if rate.changes.any? && rate.save
        updated << rate.target_id if update
        added << rate.target_id if add
      end
    end

    [added, updated, not_imported]
  end
end
