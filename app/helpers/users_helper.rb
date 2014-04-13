module UsersHelper
  def self.localized_name entry, current_user
    if entry.class == Genre
      # жанры
      if !current_user || (current_user && current_user.preferences.russian_genres? && entry.russian.present?)
        entry.russian || entry.name
      else
        entry.name
      end

    else
      # аниме
      if current_user && current_user.preferences.russian_names? && entry.respond_to?(:russian) && entry.russian.present?
        entry.russian.html_safe
      else
        entry.name.html_safe
      end
    end
  end

  # название с учётом настроек отображения русского языка
  def localized_name entry
    UsersHelper.localized_name entry, current_user
  end

  # тип с учётом настроек отображения русского языка
  def localized_kind entry, short=false
    if !current_user || (current_user && current_user.preferences.russian_genres?)
      I18n.t "#{entry.decorated? ? entry.object.class.name : entry.class.name}.#{short ? 'Short.' : ''}#{entry.kind}"
    else
      entry.kind
    end
  end

  def page_background
    if user_signed_in? && current_user.preferences.page_background.to_f > 0
      color = 255 - current_user.preferences.page_background.to_f.ceil
      "background-color: rgb(#{color},#{color},#{color});"
    end
  end

  def page_border
    if user_signed_in? && current_user.preferences.page_border
      :bordered
    end
  end

  def body_background
    if user_signed_in? && current_user.preferences.body_background.present?
      background = current_user.preferences.body_background
      if background =~ %r{^https?://}
        "background: url(#{background}) fixed no-repeat;"
      else
        "background: #{background};"
      end
    end
  end

  #def own_profile?
    #user_signed_in? && current_user.id == @user.id
  #end

  ## форматирование истории аниме
  ## obsolete
  #def format_user_history entry, only_target_name=false, add_nazad=false, no_timestamp=false
    #target_name = entry.target_id ? truncate(entry.target.name, length: 55) : nil
    ##link = link_to truncate(target_name, length: 40, omission: '...'), build_anime_url(entry.target)
    #content = if only_target_name
      #target_name
    #else
      #case entry.action
        #when UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport, UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport
          #content = "Импортирован список %s, #{entry.value} %s" % [[UserHistoryAction::MalAnimeImport, UserHistoryAction::ApAnimeImport].include?(entry.action) ? 'аниме' : 'манги',
                                                                   #Russian.p(entry.value.to_i, 'запись', 'записи', 'записей')]

        #when UserHistoryAction::Add
          #content = 'Добавлено в список <span class="highlight">%s</span>' % target_name

        #when UserHistoryAction::Delete
          #content = 'Удалено из списка <span class="highlight">%s</span>' % target_name

        #when UserHistoryAction::Status
          #content = '%s <span class="highlight">%s</span>' % [t("#{entry.target.class.name}RateStatus.%s" % UserRateStatus.get(entry.value.to_i)), target_name]

        #when UserHistoryAction::Episodes, UserHistoryAction::Volumes, UserHistoryAction::Chapters
          #counter = case entry.action
            #when UserHistoryAction::Episodes
              #'episodes'
            #when UserHistoryAction::Volumes
              #'volumes'
            #when UserHistoryAction::Chapters
              #'chapters'
          #end

          #content = if entry.target.send(counter) == entry.send(counter).last
            #if entry.target.kind == 'Movie' && entry.target.send(counter) == 1
              #'Просмотрен фильм'
            #else
              #case entry.action
                #when UserHistoryAction::Episodes
                  #'Просмотрены все эпизоды'
                #when UserHistoryAction::Volumes, UserHistoryAction::Chapters
                  #"Прочитана #{entry.target == 'Novel' ? 'новелла' : 'манга'}"
              #end
            #end
          #else
            #if entry.send(counter).size == 1 && entry.send(counter).first == 0
              #case entry.action
                #when UserHistoryAction::Episodes
                  #'Сброшено число эпизодов'
                #when UserHistoryAction::Volumes, UserHistoryAction::Chapters
                  #'Сброшено число томов и глав'
              #end
            #else
              #format_watched_episodes entry.send("watched_#{counter}"), entry.prior_value.to_i, counter
            #end
          #end + (' <span class="highlight">%s</span>' % target_name)

        #when UserHistoryAction::Rate
          #if entry.value == '0'
            #content = 'Отменена оценка <span class="highlight">%s</span>' % target_name
          #elsif entry.prior_value && entry.prior_value != '0'
            #content = 'Изменена оценка c <b>%s</b> на <b>%s</b> для <span class="highlight">%s</span>' % [entry.prior_value, entry.value, target_name]
          #else
            #content = 'Оценено <span class="highlight">%s</span> на <b>%s</b>' % [target_name, entry.value]
          #end

        #when UserHistoryAction::CompleteWithScore
          #"#{t "#{entry.target.class.name}RateStatus.#{UserRateStatus::Completed}"} и оценено <span class=\"highlight\">#{target_name}</span> на <b>#{entry.value}</b>"

        #else
          #content = target_name
      #end
    #end
    #'<a href="%s"><span class="date">%s</span><span class="event">%s</span></a>' % [
        #url_for(entry.target),
        #no_timestamp ? '' : (add_nazad ? ("%s назад" % time_ago_in_words(entry.updated_at)) : time_ago_in_words(entry.updated_at)),
        #content
      #]
  #end

  ## obsolete
  #@@t = {
    #'Просмотрен' => {
      #'episodes' => 'Просмотрен',
      #'volumes' => 'Прочитан',
      #'chapters' => 'Прочитана'
    #},
    #'Просмотрены' => {
      #'episodes' => 'Просмотрены',
      #'volumes' => 'Прочитаны',
      #'chapters' => 'Прочитаны'
    #},
    #'Просмотрено' => {
      #'episodes' => 'Просмотрено',
      #'volumes' => 'Прочитано',
      #'chapters' => 'Прочитано'
    #},
    #'эпизод' => {
      #'episodes' => 'эпизод',
      #'volumes' => 'том',
      #'chapters' => 'глава'
    #},
    #'эпизода' => {
      #'episodes' => 'эпизода',
      #'volumes' => 'тома',
      #'chapters' => 'глава'
    #},
    #'эпизодов' => {
      #'episodes' => 'эпизодов',
      #'volumes' => 'томов',
      #'chapters' => 'главы'
    #},
    #'эпизоды' => {
      #'episodes' => 'эпизоды',
      #'volumes' => 'тома',
      #'chapters' => 'главы'
    #}
  #}
  ## obsolete
  #def format_watched_episodes episodes, prior_value, counter
    #suffix = counter == 'chapters' ? 'я' : 'й'

    #if episodes.last && episodes.last < prior_value
      #"%s #{episodes.last} %s" % [Russian.p(episodes.last, @@t["Просмотрен"][counter], @@t["Просмотрены"][counter], @@t["Просмотрено"][counter]),
                                  #Russian.p(episodes.last, @@t["эпизод"][counter], @@t["эпизода"][counter], @@t["эпизодов"][counter])]
    #elsif episodes.size == 1
      #"#{@@t["Просмотрен"][counter]} #{episodes.first}#{suffix} #{@@t["эпизод"][counter]}"
    #elsif episodes.size == 2
      #"#{@@t["Просмотрены"][counter]} #{episodes.first}#{suffix} и #{episodes.last}#{suffix} #{@@t["эпизоды"][counter]}"
    #elsif episodes.size == 3
      #"#{@@t["Просмотрены"][counter]} #{episodes.first}#{suffix}, #{episodes.second}#{suffix} и #{episodes.last}#{suffix} #{@@t["эпизоды"][counter]}"
    #elsif episodes.first == 1
      #"%s #{episodes.last} %s" % [Russian.p(episodes.last, @@t["Просмотрен"][counter], @@t["Просмотрены"][counter], @@t["Просмотрено"][counter]),
                                  #Russian.p(episodes.last, @@t["эпизод"][counter], @@t["эпизода"][counter], @@t["эпизодов"][counter])]
    #else
      #"#{@@t["Просмотрены"][counter]} с #{episodes.first}%s по #{episodes.last}%s #{@@t["эпизоды"][counter]}" % [
          #counter == 'chapters' ? 'й' : 'го',
          #counter == 'chapters' ? 'ю' : suffix
        #]
    #end
  #end

  ## форматирование истории комментариев
  #def format_user_comment entry
    #commentable_class = entry.commentable.class.name
    #url = ''
    #case commentable_class
      #when Page.name
        #target = Page.find entry.commentable_id
        #url = '/'+target.permalink
        #content = 'Комментарий на странице <span class="highlight">%s</span>' % [target.name]

      #when Topic.name
        #target = Topic.find entry.commentable_id
        #url = topic_url target
        #content = 'Сообщение в теме <span class="highlight">%s</span>' % [truncate(target.title, length: 40)]

      #when AniMangaComment.name
        #target = AniMangaComment.find entry.commentable_id
        #url = send "page_#{target.linked_type.downcase}_url", target.linked, page: :comments, only_path: false
        #content = 'Отзыв на %s <span class="highlight">%s</span>' % [target.linked_type == Anime.name ? 'аниме' : 'мангу', target.linked.name]

      #when CharacterComment.name
        #target = CharacterComment.find entry.commentable_id
        #url = send "page_#{target.linked_type.downcase}_url", target.linked, page: :comments, only_path: false
        #content = 'Отзыв о персонаже <span class="highlight">%s</span>' % [target.linked.name]

      #when CosplaySession.name
        #target = CosplaySession.includes(:animes).find(entry.commentable_id)
        #if target.animes.empty?
          #content = entry.commentable_type
        #else
          #url = cosplay_anime_url target.animes.first, character: :all, gallery: target, only_path: false
          #content = 'Комментарий к косплею <span class="highlight">%s</span>>' % [target.target]
        #end

      #when AnimeNews.name
        #target = Entry.find entry.commentable_id
        #url = build_news_url target
        #content = 'Комментарий к новости аниме <span class="highlight">%s</span>' % [target.title]

      #when User.name
        #target = User.find entry.commentable_id
        #url = user_url target
        #content = 'Сообщение в профиле пользователя <span class="highlight">%s</span>' % [target.nickname]

      #when Group.name
        #target = Group.find entry.commentable_id
        #url = group_url target
        #content = 'Сообщение в группе <span class="highlight">%s</span>' % [target.name]

      #else
        #content = commentable_class
    #end
    #'<a href="%s"><span class="date">%s</span><span class="event">%s</span></a>' % [
        #url,
        #time_ago_in_words(entry.created_at),
        #content
      #]
  #end
end
