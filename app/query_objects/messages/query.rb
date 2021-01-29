class Messages::Query < QueryObjectBase
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

  def self.fetch user, messages_type
    ignores_ids = user.ignores.map(&:target_id) << 0

    new Message
      .where(where_by_type(messages_type))
      .where(where_by_sender(user, messages_type))
      .where.not(from_id: ignores_ids, to_id: ignores_ids)
      .includes(:linked, :from, :to)
      .order(*order_by_type(messages_type))
  end

  class << self
    def where_by_type type
      case type
        when :inbox, :sent then { kind: MessageType::PRIVATE }
        when :private then { kind: MessageType::PRIVATE, read: false }
        when :news then { kind: NEWS_KINDS }
        when :notifications then { kind: NOTIFICATION_KINDS }
        else raise ArgumentError, "unknown type: #{type}"
      end
    end

    def where_by_sender user, type
      case type
        when :sent then { from_id: user.id }
        when :news then { to_id: user.id }
        else { to_id: user.id, is_deleted_by_to: false }
      end
    end

    def order_by_type type
      case type
        when :private then Arel.sql('read, (case when read=true then -id else id end)')
        else [id: :desc]
      end
    end
  end
end
