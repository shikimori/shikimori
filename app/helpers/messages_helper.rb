module MessagesHelper
  def should_show_more?(message)
    [Entry.name].include?(message.linked_type) &&
      ![MessageType::QuotedByUser, MessageType::SubscriptionCommented].include?(message.kind) &&
        message.linked_id != 0
  end

  def get_message_body(message)
    case message.kind
      when MessageType::ProfileCommented
        "%s %s что-то в вашем %s..." % [
            link_to(message.src.nickname, user_url(message.src)),
            message.src.sex == 'female' ? 'написала' : 'написал',
            link_to('профиле', user_url(message.dst), rel: :slider)
          ]

      when MessageType::FriendRequest
        "%s %s вас в список друзей. Занести %s в список ваших друзей?" % [
            link_to(message.src.nickname, user_url(message.src)),
            message.src.sex == 'female' ? 'добавила' : 'добавил',
            message.src.sex == 'female' ? 'её' : 'его'
          ]

      when MessageType::QuotedByUser
        "%s %s что-то вам %s" % [
            link_to(message.src.nickname, user_url(message.src)),
            message.src.sex == 'female' ? 'написала' : 'написал',
            format_entity_name(message)
          ]

      when MessageType::SubscriptionCommented
        "Новые сообщения %s" % [
            format_entity_name(message)
          ]

      when MessageType::Warned
        "Вам вынесено предупреждение за комментарий %s" % [
            format_entity_name(message)
          ]

      when MessageType::Banned
        msg = "Вы забанены на #{message.linked.duration.humanize}"

        if message.linked.comment
          "#{msg} за комментарий %s" % [
              format_entity_name(message)
            ]
        else
          "#{msg}. Причина: \"#{message.linked.reason}\""
        end

      else
        format_comment(cut(
          message.body || message.linked.text
        ), message.src)
    end
  end

  def format_entity_name(message)
    if message.linked_type == Comment.name
      format_linked_name message.linked.commentable_id, message.linked.commentable_type, message.linked.id
    elsif message.linked_type == Ban.name
      format_linked_name message.linked.comment.commentable_id, message.linked.comment.commentable_type, message.linked.comment.id
    else
      format_linked_name message.linked_id, message.linked_type
    end
  end

  def format_linked_name(linked_id, linked_type, comment_id=nil)
    url = ''
    content = case linked_type
      when AniMangaComment.name
        target = AniMangaComment.find(linked_id)
        url = self.send("page_#{target.linked_type.downcase}_url", target.linked, page: :comments)
        'в обсуждении %s <!--%s-->.' % [target.linked_type == Anime.name ? 'аниме' : 'манги', target.linked.name]

      when CharacterComment.name
        target = CharacterComment.find(linked_id)
        url = self.send("page_#{target.linked_type.downcase}_url", target.linked, page: :comments)
        'в обсуждении персонажа <!--%s-->.' % [target.linked.name]

      when CosplaySession.name
        target = CosplaySession.includes(:animes).find(linked_id)
        if target.animes.empty?
          linked_type
        else
          url = cosplay_anime_url(target.animes.first, character: :all,
                                                       gallery: target,
                                                       only_path: false)
          'в комментариях к косплею <!--%s-->.' % [target.target]
        end

      when AnimeNews.name, Topic.name, Entry.name
        target = Entry.find_by_id linked_id
        if target
          url = topic_url(target)
          'в топике <!--%s-->' % [target.title]
        else
          'в <em>удалённом</em> топике'
        end

      when User.name
        target = User.find_by_id linked_id
        if target
          url = user_url(target)
          'в профиле пользователя <!--%s-->.' % [target.nickname]
        else
          'в профиле <em>удалённого</em> пользователя'
        end

      when Group.name
        target = Group.find_by_id linked_id
        if target
          url = club_url(target)
          'в группе <!--%s-->' % [target.name]
        else
          'в <em>удалённой</em> группе'
        end

      else
        linked_type
    end

    comment_bubble = "class=\"bubbled\" data-remote=\"true\" data-href=\"#{comment_url(id: comment_id)}\"" if comment_id
    content.sub('<!--',  "<a href=\"#{url}#{"#comment-#{comment_id}" if comment_id}\"#{comment_bubble || ''}>").sub('-->',  '</a>')
  end
end
