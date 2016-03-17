class MessagesQuery < SimpleQueryBase
  pattr_initialize :user, :messages_type

  NEWS_KINDS = [
    MessageType::Anons,
    MessageType::Ongoing,
    MessageType::Episode,
    MessageType::Released,
    MessageType::SiteNews,
    MessageType::ContestFinished
  ]
  NOTIFICATION_KINDS = [
    MessageType::FriendRequest,
    MessageType::ClubRequest,
    MessageType::Notification,
    MessageType::ProfileCommented,
    MessageType::QuotedByUser,
    MessageType::SubscriptionCommented,
    MessageType::NicknameChanged,
    MessageType::Banned,
    MessageType::Warned,
    MessageType::VersionAccepted,
    MessageType::VersionRejected,
  ]

  def query
    Message
      .where(where_by_type)
      .where(id_field => @user.id, del_field => false)
      .where.not(from_id: ignores_ids, to_id: ignores_ids)
      .includes(:linked, :from, :to)
      .order(*order_by_type)
  end

  def where_by_type
    case @messages_type
      when :inbox then { kind: [MessageType::Private] }
      when :private then { kind: [MessageType::Private], read: false }
      when :sent then { kind: [MessageType::Private] }
      when :news then { kind: NEWS_KINDS }
      when :notifications then { kind: NOTIFICATION_KINDS }
      else raise ArgumentError, "unknown type: #{@messages_type}"
    end
  end

private

  def ignores_ids
    @ignores_ids ||= @user.ignores.map(&:target_id) << 0
  end

  def order_by_type
    case @messages_type
      when :private then 'read, (case when read=true then -id else id end)'
      else [:read, id: :desc]
    end
  end


  def id_field
    if @messages_type == :sent
      :from_id
    else
      :to_id
    end
  end

  def del_field
    if @messages_type == :sent
      :is_deleted_by_from
    else
      :is_deleted_by_to
    end
  end
end
