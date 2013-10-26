# импортер аниме и манги в профиль пользователя
module AniMangaListImporter
  Counters = [:episodes, :volumes, :chapters]

  # импорт списка
  # третьим параметром ожидается массив хешей с ключами :id, :score, :status, :episodes, :chapters, :volumes
  # :status должен быть словом, не циферкой
  def import(user, klass, list_to_import, rewrite_existed)
    # уже имеющееся у пользователя в списке
    rates = user.send("#{klass.name.downcase}_rates").all.inject({}) do |data,entry|
      data[entry.target_id] = entry
      data
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
        rate = UserRate.new(user_id: user.id, target_id: entry[:id], target_type: klass.name)
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
      rate.status = UserRateStatus.get(entry[:status])
      rate.score = entry[:score].to_i
      rate.score = 10 if rate.score > 10
      rate.score = 0 if rate.score < 0

      if rate.save
        updated << rate.target_id if update
        added << rate.target_id if add
      else
        # нельзя указать больше эпизодов,частей,томов, чем имеется в аниме/манге
        Counters.each do |counter|
          if rate.errors.keys.include?(counter)
            rate[counter] = rate.send(klass.name.downcase)[counter]
            if rate.save
              updated << rate.target_id if update
              added << rate.target_id if add
              next
            end
          end
        end
      end
    end

    [added, updated, not_imported]
  end
end
