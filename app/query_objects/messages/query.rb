class Messages::Query < QueryObjectBase
  InboxType = Types::Strict::Symbol
    .enum(:inbox, :sent, :private, :news, :notifications)

  IGNORE_SUPPORTED_INBOX_TYPES = [
    InboxType[:private],
    InboxType[:inbox],
    InboxType[:sent]
  ]

  NEWS_KINDS = [
    MessageType::ANONS,
    MessageType::ONGOING,
    MessageType::EPISODE,
    MessageType::RELEASED,
    MessageType::SITE_NEWS,
    MessageType::CONTEST_STARTED,
    MessageType::CONTEST_FINISHED,
    MessageType::CLUB_BROADCAST
  ]
  NOTIFICATION_KINDS = [
    MessageType::FRIEND_REQUEST,
    MessageType::CLUB_REQUEST,
    MessageType::NOTIFICATION,
    MessageType::PROFILE_COMMENTED,
    MessageType::QUOTED_BY_USER,
    MessageType::SUBSCRIPTION_COMMENTED,
    MessageType::NICKNAME_CHANGED,
    MessageType::BANNED,
    MessageType::WARNED,
    MessageType::VERSION_ACCEPTED,
    MessageType::VERSION_REJECTED
  ]

  def self.fetch user, type
    inbox_type = InboxType[type]

    scope = Message
      .includes(:linked, :from, :to)
      .order(*order_by_type(inbox_type))

    scope.where! where_by_inbox_type(inbox_type)
    scope.where! where_by_sender(user, inbox_type)

    if IGNORE_SUPPORTED_INBOX_TYPES.include? inbox_type
      ignores_ids = user.ignores.map(&:target_id)
      scope = scope
        .where.not(from_id: ignores_ids)
        .where.not(to_id: ignores_ids)
    end

    new scope
  end

  class << self
    def where_by_inbox_type inbox_type
      case inbox_type
        when InboxType[:inbox], InboxType[:sent] then { kind: MessageType::PRIVATE }
        when InboxType[:private] then { kind: MessageType::PRIVATE, read: false }
        when InboxType[:news] then { kind: NEWS_KINDS }
        when InboxType[:notifications] then { kind: NOTIFICATION_KINDS }
      end
    end

    def where_by_sender user, inbox_type
      case inbox_type
        when InboxType[:sent] then { from_id: user.id }
        when InboxType[:news], InboxType[:notifications] then { to_id: user.id }
        else { to_id: user.id, is_deleted_by_to: false }
      end
    end

    def order_by_type inbox_type
      case inbox_type
        when InboxType[:private] then Arel.sql('read, (case when read=true then -id else id end)')
        else [id: :desc]
      end
    end
  end
end
