class MessagesQuery < QueryObjectBase
  pattr_initialize :user, :messages_type

  NEWS_KINDS = [MessageType::Anons, MessageType::Ongoing, MessageType::Episode, MessageType::Release, MessageType::SiteNews]

  def query
    Message
      .where(kind: kinds_by_type)
      .where(id_field => @user.id, del_field => false)
      .where.not(from_id: ignores_ids, to_id: ignores_ids)
      .includes(:linked, :from, :to)
      .order(*order_by_type)
  end

  def kinds_by_type
    case @messages_type
      when :private then [MessageType::Private]
      when :sent then [MessageType::Private]
      when :news then NEWS_KINDS

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

      else '-1'
    end
  end

private
  def ignores_ids
    @ignores_ids ||= @user.ignores.map(&:target_id) << 0
  end

  def order_by_type
    case @messages_type
      when :private then [:read, :id]
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
      :src_del
    else
      :dst_del
    end
  end
end
