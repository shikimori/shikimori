class UserHistory < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :target, polymorphic: true
  belongs_to :anime, foreign_key: :target_id
  belongs_to :manga, foreign_key: :target_id

  BackwardCheckInterval = 30.minutes
  DeleteBackwardCheckInterval = 60.minutes
  EpisodeBackwardCheckInterval = 6.hours

  # look at spec for additional info
  def self.add(user, item, action, value=nil, prior_value=nil)
    # при изменении на тоже самое значение ничего не делаем
    return if value && value == prior_value
    last_entry = UserHistory
      .where(user_id: user.is_a?(Fixnum) ? user : user.id)
      .where(target_type: item.class.name)
      .order(id: :desc)
      .first

    # аниме просмотрено и сразу же поставлена оценка
    if last_entry && last_entry.target_type == item.class.name && last_entry.target_id == item.id &&
      ((action == UserHistoryAction::Status && value == UserRateStatus.get(UserRateStatus::Completed) && last_entry.action == UserHistoryAction::Rate) ||
        (action == UserHistoryAction::Rate && last_entry.action == UserHistoryAction::Status && last_entry.value.to_i == UserRateStatus.get(UserRateStatus::Completed)))

      last_entry.update_attributes(action: UserHistoryAction::CompleteWithScore,
                                   value: action == UserHistoryAction::Status ? last_entry.value : value)
      return
    end

    no_last_this_entry_search = false
    case action
      when UserHistoryAction::Status

      when UserHistoryAction::Add
        last_delete = UserHistory.where(user_id: user.is_a?(Fixnum) ? user : user.id)
            .where(target_type: item.class.name)
            .where(target_id: item.id)
            .where(action: UserHistoryAction::Delete)
            .where("updated_at > ?", DateTime.now - DeleteBackwardCheckInterval)
            .order(:id)
            .first
        if last_delete
          last_delete.destroy
          return
        end

      when UserHistoryAction::Delete
        prior_entries = UserHistory.where(user_id: user.is_a?(Fixnum) ? user : user.id)
            .where(target_type: item.class.name)
            .where(target_id: item.id)
            .where("updated_at > ?", DateTime.now - DeleteBackwardCheckInterval)
            .order(:id)
            .to_a

        if last_entry && last_entry.action == UserHistoryAction::Add && last_entry.target_id == item.id
          last_entry.destroy
          return
        end
        if !prior_entries.empty? && prior_entries.first.action == UserHistoryAction::Add
          prior_entries.each {|v| v.destroy }
          return
        else
          prior_entries.each {|v| v.destroy }
        end

      when UserHistoryAction::Rate
        # если prior_value=nil, то считаем, что это ноль
        prior_value = 0 unless prior_value
        raise RuntimeError.new("Got prior_value #{prior_value.class.name}, but expected Fixnum") unless prior_value.is_a?(Fixnum) || prior_value.is_a(Bignum)
        raise RuntimeError.new("Got value #{prior_value.class.name}, but expected Fixnum") unless value.is_a?(Fixnum) || value.is_a(Bignum)

        value = 10 if value > 10
        value = 0 if value < 0

        # если сняли оценку(поставили 0), а недавно её поставили, то удаляем обе записи
        if value == 0 && last_entry && last_entry.action == UserHistoryAction::Rate && last_entry.target_id == item.id
          last_entry.destroy
          return
        end
        # если поставили поставили 0, и раньше был ноль, то ничего не делаем
        if value == 0 && prior_value == 0
          return
        end

      when UserHistoryAction::Episodes, UserHistoryAction::Volumes, UserHistoryAction::Chapters
        counter = case action
          when UserHistoryAction::Episodes
            'episodes'
          when UserHistoryAction::Volumes
            'volumes'
          when UserHistoryAction::Chapters
            'chapters'
        end

        no_last_this_entry_search = true
        raise RuntimeError.new("Got value #{value.class.name}, but expected Fixnum") unless value.is_a?(Fixnum)

        # если prior_value=nil, то считаем, что это ноль
        prior_value = 0 unless prior_value
        raise RuntimeError.new("Got prior_value #{prior_value.class.name}, but expected Fixnum") unless prior_value.is_a?(Fixnum)

        prior_entries = UserHistory
          .where(user_id: user.is_a?(Fixnum) ? user : user.id)
          .where(target_type: item.class.name)
          .where(target_id: item.id)
          .where(action: action)
          .where("updated_at > ?", DateTime.now - EpisodeBackwardCheckInterval)
          .order(:id)
          .to_a

        if prior_entries.any? && prior_entries.last.value.size < 250
          # если предыдущее событие было с эпизодом этого же аниме,
          # то откидываем более поздние эпизоды из списка и добавляем текущий эпизод в конец списка
          unless value == 0
            last_this_entry = prior_entries.last
            episode = value.to_i
            new_episdodes = last_this_entry.send(counter).clone
            last_this_entry.send(counter).reverse.each do |v|
              if v < episode
                new_episdodes << episode
                # ситуация, когда посмотрели новые эпизоды, а отмечаем более старые
                if new_episdodes.last == last_this_entry.prior_value.to_i
                  last_this_entry.destroy
                  return
                end
                last_this_entry.send "#{counter}=", new_episdodes
                last_this_entry.save
                return
              elsif v == episode
                last_this_entry.send "#{counter}=", new_episdodes
                last_this_entry.save
                return
              else
                new_episdodes.pop
              end
            end
          end

          # если поставили 0 эпизодов, а до этого были другие эпизоды, и начинали с нуля, то удаляем все записи
          if value == 0 && prior_entries.first.prior_value == "0"
            prior_entries.each {|v| v.destroy }
            return
          end
          # если поставили 0 эпизодов, а до этого были другие эпизоды, но начинали не с нуля, то удаляем сколько сможем и пишем записть о добавлении 0 эпизодов
          if value == 0 && prior_entries.first.prior_value != "0"
            prior_entries.each {|v| v.destroy }
          end
        end
    end

    unless no_last_this_entry_search
      entry = UserHistory.where("updated_at > ?", DateTime.now - BackwardCheckInterval)
          .where(user_id: user.is_a?(Fixnum) ? user : user.id)
          .where(target_id: item.id)
          .where(target_type: item.class.name)
          .where(action: action)
          .first

      if entry && action == UserHistoryAction::Rate
        # для оценок изначальную оценку не меняем
        prior_value = entry.prior_value

        # если меняли несколько раз оценку и в конце-концов поставили старую назад,
        # то нам запись в истории совсем не нужна - удаляем её
        if prior_value.to_i == value
          entry.destroy
          return
        end
      end
    end

    entry ||= UserHistory.new({
        user_id: user.is_a?(Fixnum) ? user : user.id,
        target_id: item.id,
        target_type: item.class.name,
        action: action
      })

    entry.value = value
    entry.prior_value = prior_value
    entry.save
    entry
  end

  ['episodes', 'volumes', 'chapters'].each do |counter|
    define_method(counter) do
      return @parsed_episodes if @parsed_episodes
      raise RuntimeError.new("Got action:#{self.action}, but expected action:#{UserHistoryAction.const_get(counter.capitalize)}") if self.action != UserHistoryAction.const_get(counter.capitalize)

      @parsed_episodes = self.value.split(',').map(&:to_i)
    end

    define_method("#{counter}=") do |value|
      raise RuntimeError.new("Got action:#{self.action}, but expected action:#{UserHistoryAction.const_get(counter.capitalize)}") if self.action != UserHistoryAction.const_get(counter.capitalize)

      @parsed_episodes = value
      self.value = @parsed_episodes.join(',')
    end

    # полный список всех эпизодов с учетом прошлых эпизодов в prior_value
    define_method("watched_#{counter}") do
      raise RuntimeError.new("Got action:#{self.action}, but expected action:#{UserHistoryAction.const_get(counter.capitalize)}") if self.action != UserHistoryAction.const_get(counter.capitalize)

      if self.send(counter).last && self.send(counter).last < prior_value.to_i
        [self.send(counter).last]
      else
        e_start = self.prior_value ? self.prior_value.to_i + 1 : self.episodes.first
        e_end = self.send(counter).last
        # бывает и такое. ушлые пользователи
        e_end = self.send(counter)[-2] || 0 if e_end > UserRate::MAXIMUM_EPISODES

        e_start.upto(e_end).inject([]) {|all,v| all << v }
      end
    end
  end
end
