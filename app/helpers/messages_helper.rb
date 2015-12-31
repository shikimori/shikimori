# TODO: refactor to MessageDecorator, не забыть MessageSerializer.body
module MessagesHelper # для truncate в messages helper
  def self.included klass
    klass.send :include, ActionView::Helpers::TextHelper # для truncate
    klass.send :include, ActionView::Helpers::SanitizeHelper
  end

  # TODO: перенести в MessageDecorator#generate_body
  def get_message_body message
    #Rails.logger.info message.to_yaml
    case message.kind
      when MessageType::ProfileCommented
        "Написал#{'а' if message.from.female?} что-то в вашем " +
          "<a class='b-link' href='#{profile_url message.to}'>профиле</a>..."

      when MessageType::FriendRequest
        "Добавил#{'а' if message.from.female?} вас в список друзей. " +
         "Добавить #{message.from.female? ? 'её' : 'его'} в свой список друзей в ответ?"

      when MessageType::QuotedByUser
        "Написал#{'а' if message.from.female?} что-то вам #{format_entity_name message}"

      when MessageType::SubscriptionCommented
        "Новые сообщения %s" % [
            format_entity_name(message)
          ]

      when MessageType::Warned
        msg = "Вам вынесено предупреждение за "

        if message.linked.comment
          "#{msg} комментарий #{format_entity_name message}."
        else
          "#{msg} удалённый комментарий. Причина: \"#{message.linked.reason}\"."
        end

      when MessageType::Banned
        msg = "Вы забанены на #{message.linked ? message.linked.duration.humanize : '???'}."

        if message.linked && message.linked.comment
          "#{msg} за комментарий #{format_entity_name message}."
        else
          "#{msg}. Причина: \"#{message.linked ? message.linked.reason : '???'}\"."
        end

      when MessageType::Private
        if message.from.bot?
          #BbCodeFormatter.instance.format_comment(cut(message.body || message.linked.text)).html_safe
          cut(message.body || message.linked.text)
        else
          message.html_body
        end

      when MessageType::Ongoing, MessageType::Anons, MessageType::Episode, MessageType::Released
        message.linked.to_s(:full)

      else
        BbCodeFormatter.instance.format_comment cut(message.body || message.linked.text)
    end
  end

  def format_entity_name message
    if message.linked_type == Comment.name
      if message.linked
        format_linked_name message.linked.commentable_id, message.linked.commentable_type, message.linked.id
      else
        '<em>в удалённом комментарии</em>.'
      end

    elsif message.linked_type == Ban.name
      format_linked_name message.linked.comment.commentable_id, message.linked.comment.commentable_type, message.linked.comment.id

    else
      format_linked_name message.linked_id, message.linked_type
    end
  end

  def format_linked_name linked_id, linked_type, comment_id=nil
    url = ''
    content = case linked_type
      when CosplayGallery.name
        target = CosplayGallery.includes(:animes).find(linked_id)
        if target.animes.empty?
          linked_type
        else
          url = cosplay_anime_url(
            target.animes.first, character: :all,
            gallery: target,
            only_path: false
          )
          'в комментариях к косплею <!--%s-->.' % [target.target]
        end

      when Entry.name
        target = Entry.find_by_id linked_id
        if target
          url = UrlGenerator.instance.topic_url(target)
          'в топике <!--%s-->.' % [truncate(target.title, length: 30, omission: '…')]
        else
          'в <em>удалённом</em> топике.'
        end

      when User.name
        target = User.find_by_id linked_id
        if target
          url = profile_url(target)
          'в профиле пользователя <!--%s-->.' % [target.nickname]
        else
          'в профиле <em>удалённого</em> пользователя.'
        end

      else
        linked_type
    end

    comment_bubble = "class=\"bubbled b-link\" data-href=\"#{comment_url(id: comment_id)}\"" if comment_id
    content.sub('<!--',  "<a href=\"#{url}#{"#comment-#{comment_id}" if comment_id}\"#{comment_bubble || ''}>").sub('-->',  '</a>')
  end
end
