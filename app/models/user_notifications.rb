# код об уведомлениях пользователя
module UserNotifications
  # notification settings
  ANONS_TV_NOTIFICATIONS         = 0x000001
  ANONS_MOVIE_NOTIFICATIONS      = 0x000002
  ANONS_OVA_NOTIFICATIONS        = 0x000004

  ONGOING_TV_NOTIFICATIONS       = 0x000010
  ONGOING_MOVIE_NOTIFICATIONS    = 0x000020
  ONGOING_OVA_NOTIFICATIONS      = 0x000040

  MY_ONGOING_TV_NOTIFICATIONS    = 0x000100
  MY_ONGOING_MOVIE_NOTIFICATIONS = 0x000200
  MY_ONGOING_OVA_NOTIFICATIONS   = 0x000400

  RELEASE_TV_NOTIFICATIONS       = 0x001000
  RELEASE_MOVIE_NOTIFICATIONS    = 0x002000
  RELEASE_OVA_NOTIFICATIONS      = 0x004000

  MY_RELEASE_TV_NOTIFICATIONS    = 0x010000
  MY_RELEASE_MOVIE_NOTIFICATIONS = 0x020000
  MY_RELEASE_OVA_NOTIFICATIONS   = 0x040000

  MY_EPISODE_TV_NOTIFICATIONS    = 0x100000
  MY_EPISODE_MOVIE_NOTIFICATIONS = 0x200000
  MY_EPISODE_OVA_NOTIFICATIONS   = 0x400000

  NOTIFICATIONS_TO_EMAIL_SIMPLE  = 0x000008
  NOTIFICATIONS_TO_EMAIL_GROUP   = 0x000080
  NOTIFICATIONS_TO_EMAIL_NONE    = 0x000800
  PRIVATE_MESSAGES_TO_EMAIL      = 0x080000
  NICKNAME_CHANGE_NOTIFICATIONS  = 0x800000

  DEFAULT_NOTIFICATIONS = MY_ONGOING_TV_NOTIFICATIONS + MY_ONGOING_MOVIE_NOTIFICATIONS + MY_ONGOING_OVA_NOTIFICATIONS +
      MY_RELEASE_TV_NOTIFICATIONS + MY_RELEASE_MOVIE_NOTIFICATIONS + MY_RELEASE_OVA_NOTIFICATIONS +
      NOTIFICATIONS_TO_EMAIL_GROUP +
      PRIVATE_MESSAGES_TO_EMAIL + NICKNAME_CHANGE_NOTIFICATIONS

  def unread_count
    unread_messages + unread_news + unread_notifications
  end

  # number of unread private messages
  def unread_messages
    ignored_ids = cached_ignores.map(&:target_id) << 0

    @unread_messages ||= Message.where(to_id: id)
        .where(kind: MessageType::Private)
        .where(read: false)
        .where.not(from_id: ignored_ids, to_id: ignored_ids)
        .count
  end

  # number of unread notifications
  def unread_news
    ignored_ids = cached_ignores.map(&:target_id) << 0
    @unread_news ||= Message.where(to_id: id)
        .where(kind: [MessageType::Anons, MessageType::Ongoing, MessageType::Episode, MessageType::Release, MessageType::SiteNews])
        .where(read: false)
        .where.not(from_id: ignored_ids, to_id: ignored_ids)
        .count
  end

  # number of unread notifications
  def unread_notifications
    ignored_ids = cached_ignores.map(&:target_id) << 0
    @unread_notifications ||= Message.where(to_id: id)
        .where(kind: [
          MessageType::FriendRequest, MessageType::GroupRequest, MessageType::Notification, MessageType::ProfileCommented,
          MessageType::QuotedByUser, MessageType::SubscriptionCommented, MessageType::NicknameChanged,
          MessageType::Banned, MessageType::Warned
        ])
        .where(read: false)
        .where.not(from_id: ignored_ids, to_id: ignored_ids)
        .count
  end

  def notify_bounced_email
    Message.create_wo_antispam!(
      from_id: BotsService.get_poster.id,
      to_id: id,
      kind: MessageType::Notification,
      body: "Наш почтовый сервис не смог доставить письмо на вашу почту #{email}.\nВы либо указали несуществующий почтовый ящик, либо когда-то пометили одно из наших писем как спам. Рекомендуем сменить e-mail в настройках профиля, иначе при утере пароля вы не сможете восстановить свой аккаунт."
    )
  end

  # возвращает подписан ли пользователь на новость
  def subscribed_for_event? entry
    if entry.kind_of?(Topic) && entry.broadcast
      entry.action = MessageType::SiteNews
      return true
    end

    if entry.linked
      return false if send("#{entry.linked.class.name.downcase}_rates").select do |v|
        v.target_id == entry.linked_id && v.dropped?
      end.any?
    end

    case entry.action
      # Anons
      when AnimeHistoryAction::Anons
        case entry.linked.kind
          when 'tv'
            self.notifications & ANONS_TV_NOTIFICATIONS != 0

          when 'movie'
            self.notifications & ANONS_MOVIE_NOTIFICATIONS != 0

          else
            self.notifications & ANONS_OVA_NOTIFICATIONS != 0
        end

      # Ongoing
      when AnimeHistoryAction::Ongoing
        result = false
        case entry.linked.kind
          when 'tv'
            result = self.notifications & ONGOING_TV_NOTIFICATIONS != 0

          when 'movie'
            result = self.notifications & ONGOING_MOVIE_NOTIFICATIONS != 0

          else
            result = self.notifications & ONGOING_OVA_NOTIFICATIONS != 0
        end
        return true if result
        self.anime_rates.any? do |rate|
          if rate.target_id == entry.linked_id
            case entry.linked.kind
              when 'tv'
                self.notifications & MY_ONGOING_TV_NOTIFICATIONS != 0

              when 'movie'
                self.notifications & MY_ONGOING_MOVIE_NOTIFICATIONS != 0

              else
                self.notifications & MY_ONGOING_OVA_NOTIFICATIONS != 0
            end
          else
            false
          end
        end

      # Release
      when AnimeHistoryAction::Release
        result = case entry.linked.kind
          when 'tv'
            self.notifications & RELEASE_TV_NOTIFICATIONS != 0

          when 'movie'
            self.notifications & RELEASE_MOVIE_NOTIFICATIONS != 0

          else
            self.notifications & RELEASE_OVA_NOTIFICATIONS != 0
        end

        return true if result
        self.anime_rates.any? do |rate|
          if rate.target_id == entry.linked_id
            case entry.linked.kind
              when 'tv'
                self.notifications & MY_RELEASE_TV_NOTIFICATIONS != 0

              when 'movie'
                self.notifications & MY_RELEASE_MOVIE_NOTIFICATIONS != 0

              else
                self.notifications & MY_RELEASE_OVA_NOTIFICATIONS != 0
            end
          else
            false
          end
        end

      # Episode
      when AnimeHistoryAction::Episode
        self.anime_rates.any? do |rate|
          if rate.target_id == entry.linked_id
            case entry.linked.kind
              when 'tv'
                self.notifications & MY_EPISODE_TV_NOTIFICATIONS != 0

              when 'movie'
                self.notifications & MY_EPISODE_MOVIE_NOTIFICATIONS != 0

              else
                self.notifications & MY_EPISODE_OVA_NOTIFICATIONS != 0
            end
          else
            false
          end
        end

      else
        false
    end
  end
end
