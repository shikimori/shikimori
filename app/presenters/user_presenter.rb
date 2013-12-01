class UserPresenter < BasePresenter
  proxy :banned?
  presents :user

  attr_reader :history
  attr_accessor :history_limit

  # конструктор
  def initialize(*args)
    super *args

    @history_limit = groups.any? ? 3 : 4#user.profile_settings.anime? && user.profile_settings.manga? ? 7 : 4
  end

  # общая личная информация
  def common_info
    info = []
    info << h(user.name)
    info << 'муж' if user.male?
    info << 'жен' if user.female?
    unless user.birth_at.blank?
      years = DateTime.now.year - user.birth_at.year
      full_years = Date.parse(DateTime.now.to_s) - years.years + 1.day > user.birth_at ? years : years - 1
      info << "#{full_years} #{Russian.p(full_years, 'год', 'года', 'лет')}" if full_years > 9
    end
    info << user.location
    info << website

    info.select! &:present?
    info << 'Нет личных данных' if info.empty?

    info.join('<span class="sep inline">/</span>')
  end

  # отформатированный сайт
  def website
    return if user.website.blank?

    url_wo_http = h(user.website).sub(/^https?:\/\//, '')
    link_to url_wo_http, "http://#{url_wo_http}", class: 'website'
  end

  # история
  def history
    @history ||= user.all_history
        .order('updated_at desc')
        .limit(@history_limit*4)
  end

  # группы
  def groups
    @groups ||= if user.profile_settings.clubs?
      user.groups.order(:name).limit(4)
    else
      []
    end
  end

  # друзья с заполненной историей
  def friends_with_history
    UserPresenter.fill_users_history user.friends.sort_by {|v| v.last_online_at }.reverse, current_user
  end

  # комментарии профиля пользователя
  def comments
    user.comments.with_viewed(current_user).order('id desc').limit(15)
  end

  # находится ли пользователь в друзьях у текущего пользователя?
  def favoured?
    @favored ||= current_user.friends.include?(user)
  end

  # заигнорен ли пользователь текущим пользователем?
  def ignored?
    @ignored ||= current_user.ignores.any? { |v| v.target_id == user.id }
  end

  # статистика по пользователю
  def stats
    @stats ||= Rails.cache.fetch("user_stats_#{entry.cache_key}_#{!current_user || (current_user && current_user.profile_settings.russian_genres?) ? 'rus' : 'en'}") do
      UserStatisticsService.new(entry, current_user).fetch
    end
  end

  # статистика по размеру списка текущей страницы
  def current_counts
    if params[:list_type] == 'anime'
      stats[:anime_statuses].select {|v| v[:size] > 0 }
    else
      stats[:manga_statuses].select {|v| v[:size] > 0 }
    end
  end

  # выборка разом всех аниме и манги из истории пользователей и заполнение данных в переданные объекты пользователей
  def self.fill_users_history(users, current_user)
    users.each do |user|
      user[:history] = user.anime_uniq_history.limit(4).all
    end
    [Anime, Manga].each do |klass|
      entries = klass
        .where(id: users.map {|user| user[:history].select {|v| v[:target_type] == klass.name }.map(&:target_id) }.flatten.uniq)
        .select([:id, :name, :russian])
        .each_with_object({}) {|v,rez| rez[v.id] = v }

      users.each do |user|
        user[:history] = user[:history].map do |h|
          if h[:target_type] == klass.name
            target = entries[h.target_id]
            target ? {
              target: target,
              name: UserPresenter.localized_name(target, current_user),
              updated_at: h.updated_at
            } : nil
          else
            h
          end
        end.compact
      end
    end
    users
  end

  # последний онлайн
  def last_online
    if user.admin?
      'всегда на сайте'
    elsif DateTime.now - 5.minutes <= user.last_online_at
      'сейчас на сайте'
    else
      "онлайн #{time_ago_in_words(user.last_online_at, nil, true)} назад"
    end
  end

  # показывать ли блок "О себе" над статистикой?
  def about_above?
    !user.about.blank? && !user.about.strip.blank? && user.profile_settings.about_on_top?
  end

  # показывать ли блок "О себе" под статистикой?
  def about_below?
    !user.about.blank? && !user.about.strip.blank? && !user.profile_settings.about_on_top?
  end

  # блок "О себе"
  def about
    BbCodeService.instance.format_comment user.about
  end

  # показывать ли ленту сообщений у пользователя
  def show_comments?
    (user_signed_in? || user.comments.any?) && user.profile_settings.comments?
  end

  # изменения никнеймов пользователя
  def nickname_changes?
    nickname_changes.any?
  end
  def nickname_changes
    @nickname_changes = user.nickname_changes.all.select {|v| v.value != user.nickname }
  end
  def nicknames_tooltip
    "Также #{user.female? ? 'известна' : 'известен'} как: " + nickname_changes.map {|v| "<b style='white-space: nowrap'>"+h(v.value)+"</b>" }.join("<span color='#555'>,</span> ")
  end

  # текст о совместимости
  def compatibility_text(number)
    if number < 5
      'нет совместимости'
    elsif number < 25
      'слабая совместимость'
    elsif number < 40
      'средняя совместимость'
    elsif number < 60
      'высокая совместимость'
    else
      'полная совместимость'
    end
  end

  # класс для контейнера текста совместимости
  def compatibility_class(number)
    if number < 5
      'zero'
    elsif number < 25
      'weak'
    elsif number < 40
      'moderate'
    elsif number < 60
      'high'
    else
      'full'
    end
  end

  # отформатированная история
  def formatted_history
    history.group_by do |v|
      "#{v.target_id || v.action[0]}_#{v.updated_at.strftime("%d-%m-%y")}"
    end.take(@history_limit).map do |group,entries|
      entry = entries.first
      if UserHistoryAction::Registration == entry.action
        {
          image: '/assets/blocks/history/shikimori.x43.png',
          name: 'shikimori.org',
          action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
          time: time_ago_in_words(entry.created_at, "%s назад"),
          url: 'http://shikimori.org'
        }
      elsif [UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport].include? entry.action
        {
          image: '/assets/blocks/history/mal.png',
          name: 'MyAnimeList',
          action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
          time: time_ago_in_words(entry.created_at, "%s назад"),
          url: 'http://myanimelist.net'
        }
      elsif [UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport].include? entry.action
        {
          image: '/assets/blocks/history/anime-planet.jpg',
          name: 'Anime-Planet',
          action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
          time: time_ago_in_words(entry.created_at, "%s назад"),
          url: 'http://anime-planet.com'
        }
      elsif entry.target.nil?
        nil
      else
        {
          image: entry.target.image.url(:x64),
          name: UserPresenter.localized_name(entry.target, current_user),
          action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
          time: time_ago_in_words(entry.created_at, "%s назад"),
          url: url_for(entry.target)
        }
      end
    end.compact.each do |entry|
      entry[:reversed_action] = entry[:action].split(/(?<!\d[йяюо]), /).reverse.join(', ').gsub(/<.*?>/, '')
    end
  end

  # название с учётом настроек отображения русского языка
  def self.localized_name(entry, current_user)
    if entry.class == Genre
      # жанры
      if !current_user || (current_user && current_user.profile_settings.russian_genres? && entry.russian.present?)
        entry.russian || entry.name
      else
        entry.name
      end

    else
      # аниме
      if current_user && current_user.profile_settings.russian_names? && entry.respond_to?(:russian) && entry.russian.present?
        entry.russian.html_safe
      else
        entry.name.html_safe
      end
    end
  end

  # название с учётом настроек отображения русского языка. русское название берётся оригинальное, не обрезанное
  def self.localized_original_name(entry, current_user)
    if current_user && current_user.profile_settings.russian_names? && entry.russian.present?
      entry[:russian].html_safe
    else
      entry.name.html_safe
    end
  end

  # тип с учётом настроек отображения русского языка
  def self.localized_kind(entry, current_user, short=false)
    if !current_user || (current_user && current_user.profile_settings.russian_genres?)
      I18n.t("#{entry.class.name}.#{short ? 'Short.' : ''}#{entry.kind}")
    else
      entry.kind
    end
  end

  def self.history_entry_text(entry)
    case entry.action
      when UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport, UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport
        "Импортирован#{[UserHistoryAction::MalAnimeImport, UserHistoryAction::ApAnimeImport].include?(entry.action) ? 'о аниме' : 'а манга'} - #{entry.value} #{Russian.p(entry.value.to_i, 'запись', 'записи', 'записей')}"

      when UserHistoryAction::Registration
        'Регистрация на сайте'

      when UserHistoryAction::Add
        'Добавлено в список'

      when UserHistoryAction::Delete
        'Удалено из списка'

      when UserHistoryAction::Status
        I18n.t("#{entry.target.class.name}RateStatus.#{UserRateStatus.get(entry.value.to_i)}")

      when UserHistoryAction::Episodes, UserHistoryAction::Volumes, UserHistoryAction::Chapters
        counter = case entry.action
          when UserHistoryAction::Episodes
            'episodes'
          when UserHistoryAction::Volumes
            'volumes'
          when UserHistoryAction::Chapters
            'chapters'
        end

        if entry.target.send(counter) == entry.send(counter).last
          if entry.target.kind == 'Movie' && entry.target.send(counter) == 1
            'Просмотрен фильм'
          else
            case entry.action
              when UserHistoryAction::Episodes
                'Просмотрены все эпизоды'
              when UserHistoryAction::Volumes, UserHistoryAction::Chapters
                "Прочитана #{entry.target == 'Novel' ? 'новелла' : 'манга'}"
            end
          end
        else
          if entry.send(counter).size == 1 && entry.send(counter).first == 0
            case entry.action
              when UserHistoryAction::Episodes
                'Сброшено число эпизодов'
              when UserHistoryAction::Volumes, UserHistoryAction::Chapters
                'Сброшено число томов и глав'
            end
          else
            self.format_watched_episodes(entry.send("watched_#{counter}"), entry.prior_value.to_i, counter)
          end
        end

      when UserHistoryAction::Rate
        if entry.value == '0'
          'Отменена оценка'
        elsif entry.prior_value && entry.prior_value != '0'
          "Изменена оценка c <b>#{entry.prior_value}</b> на <b>#{entry.value}</b>"
        else
          "Оценено на <b>#{entry.value}</b>"
        end

      when UserHistoryAction::CompleteWithScore
        "#{I18n.t("#{entry.target.class.name}RateStatus.#{UserRateStatus::Completed}")} и оценено на <b>#{entry.value}</b>"

      else
        entry.target.name
    end
  end

  #TODO: вынести логику в WatchedEpisodesFormatter
  def self.format_watched_episodes(episodes, prior_value, counter)
    suffix = counter == 'chapters' ? 'я' : 'й'

    if episodes.last && episodes.last < prior_value
      "%s #{episodes.last} %s" % [Russian.p(episodes.last, @@t["Просмотрен"][counter], @@t["Просмотрены"][counter], @@t["Просмотрено"][counter]),
                                  Russian.p(episodes.last, @@t["эпизод"][counter], @@t["эпизода"][counter], @@t["эпизодов"][counter])]
    elsif episodes.size == 1
      "#{@@t["Просмотрен"][counter]} #{episodes.first}#{suffix} #{@@t["эпизод"][counter]}"
    elsif episodes.size == 2
      "#{@@t["Просмотрены"][counter]} #{episodes.first}#{suffix} и #{episodes.last}#{suffix} #{@@t["эпизоды"][counter]}"
    elsif episodes.size == 3
      "#{@@t["Просмотрены"][counter]} #{episodes.first}#{suffix}, #{episodes.second}#{suffix} и #{episodes.last}#{suffix} #{@@t["эпизоды"][counter]}"
    elsif episodes.first == 1
      "%s #{episodes.last} %s" % [Russian.p(episodes.last, @@t["Просмотрен"][counter], @@t["Просмотрены"][counter], @@t["Просмотрено"][counter]),
                                  Russian.p(episodes.last, @@t["эпизод"][counter], @@t["эпизода"][counter], @@t["эпизодов"][counter])]
    else
      "#{@@t["Просмотрены"][counter]} с #{episodes.first}%s по #{episodes.last}%s #{@@t["эпизоды"][counter]}" % [
          counter == 'chapters' ? 'й' : 'го',
          counter == 'chapters' ? 'ю' : suffix
        ]
    end
  end

  @@t = {
    'Просмотрен' => {
      'episodes' => 'Просмотрен',
      'volumes' => 'Прочитан',
      'chapters' => 'Прочитана'
    },
    'Просмотрены' => {
      'episodes' => 'Просмотрены',
      'volumes' => 'Прочитаны',
      'chapters' => 'Прочитаны'
    },
    'Просмотрено' => {
      'episodes' => 'Просмотрено',
      'volumes' => 'Прочитано',
      'chapters' => 'Прочитано'
    },
    'эпизод' => {
      'episodes' => 'эпизод',
      'volumes' => 'том',
      'chapters' => 'глава'
    },
    'эпизода' => {
      'episodes' => 'эпизода',
      'volumes' => 'тома',
      'chapters' => 'главы'
    },
    'эпизодов' => {
      'episodes' => 'эпизодов',
      'volumes' => 'томов',
      'chapters' => 'глав'
    },
    'эпизоды' => {
      'episodes' => 'эпизоды',
      'volumes' => 'тома',
      'chapters' => 'главы'
    }
  }
end
