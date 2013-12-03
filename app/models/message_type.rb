# TODO: refactor to Message.enumerize
class MessageType
  # личное сообщение
  Private = 'Private'
  # уведомление
  Notification = 'Notification'
  # уведомление об анонсе
  Anons = AnimeHistoryAction::Anons
  # уведомление об онгоинге
  Ongoing = AnimeHistoryAction::Ongoing
  # уведомление о релизе
  Release = AnimeHistoryAction::Release
  # уведомление о эпизоде
  Episode = AnimeHistoryAction::Episode
  # запрос на добавление в друзья
  FriendRequest = 'FriendRequest'
  # пришлашение в группу
  GroupRequest = 'GroupRequest'
  # новость сайта
  SiteNews = 'SiteNews'
  # прокомментирован профиль
  ProfileCommented = 'ProfileCommented'
  # пользователь процитирован кем-то где-то
  QuotedByUser = 'QuotedByUser'
  # комментарий в подписанной сущности
  SubscriptionCommented = 'SubscriptionCommented'
  # уведомление о смене ника
  NicknameChanged = 'NicknameChanged'
  # уведомление о бане
  Banned = 'Banned'
  # уведомление о предупреждении
  Warned = 'Warned'
end
