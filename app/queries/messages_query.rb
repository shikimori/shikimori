class MessagesQuery
  pattr_initialize :user, :messages_type

  def fetch page, limit
    Message
      .where(kind: kinds)
      .where(id_field => @user.id, del_field => false)
      .where.not(from_id: ignores_ids, to_id: ignores_ids)
      .includes(:linked, :from, :to)
      .order(:read, created_at: :desc)
      .offset(limit * (page-1))
      .limit(limit + 1)
  end

  def postload page, limit
    collection = fetch(page, limit).to_a
    [collection.take(limit), collection.size == limit+1]
  end

private
  def ignores_ids
    @ignores_ids ||= @user.ignores.map(&:target_id) << 0
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
      :src_del
    else
      :dst_del
    end
  end

  def kinds
    case @messages_type
      when :inbox
        [MessageType::Private]

      when :sent
        #[MessageType::Private, MessageType::Notification]
        [MessageType::Private]

      when :news
        [MessageType::Anons, MessageType::Ongoing, MessageType::Episode, MessageType::Release, MessageType::SiteNews]

      when :notifications
        [
          MessageType::FriendRequest,
          MessageType::GroupRequest,
          MessageType::Notification,
          MessageType::ProfileCommented,
          MessageType::QuotedByUser,
          MessageType::SubscriptionCommented,
          MessageType::NicknameChanged,
          MessageType::Banned,
          MessageType::Warned
        ]

      else
        '-1'
    end
  end
end
