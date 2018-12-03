# TODO: refactor to Message.enumerize
class MessageType
  # личное сообщение
  PRIVATE = 'Private'
  # уведомление
  NOTIFICATION = 'Notification'
  # уведомление об анонсе
  ANONS = AnimeHistoryAction::Anons
  # уведомление об онгоинге
  ONGOING = AnimeHistoryAction::Ongoing
  # уведомление о релизе
  RELEASED = AnimeHistoryAction::Released
  # уведомление о эпизоде
  EPISODE = AnimeHistoryAction::Episode
  # запрос на добавление в друзья
  FRIEND_REQUEST = 'FriendRequest'
  # пришлашение в клуб
  CLUB_REQUEST = 'ClubRequest'
  # новость сайта
  SITE_NEWS = 'SiteNews'
  # прокомментирован профиль
  PROFILE_COMMENTED = 'ProfileCommented'
  # пользователь процитирован кем-то где-то
  QUOTED_BY_USER = 'QuotedByUser'
  # комментарий в подписанной сущности
  SUBSCRIPTION_COMMENTED = 'SubscriptionCommented'
  # уведомление о смене ника
  NICKNAME_CHANGED = 'NicknameChanged'
  # уведомление о бане
  BANNED = 'Banned'
  # уведомление о предупреждении
  WARNED = 'Warned'
  # уведомление о принятии/отказе правки
  VERSION_ACCEPTED = 'VersionAccepted'
  VERSION_REJECTED = 'VersionRejected'
  # уведомление о завершении опроса
  CONTEST_STARTED = 'ContestStarted'
  CONTEST_FINISHED = 'ContestFinished'
  CLUB_BROADCAST = 'ClubBroadcast'

  ANIME_RELATED = [ANONS, ONGOING, RELEASED, EPISODE]
end
