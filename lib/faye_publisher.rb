# Публикация различных уведомлений через Faye
# FayePublisher.publish({ data: { comment_id: 2919 } }, ['/topic-77141'])
# FayePublisher.publish({ data: { comment_id: 2919, topic_id: 77141 } }, ['/section-1'])
module FayePublisher
  BroadcastFeed = 'myfeed'
  @ns = ''

  # отправка уведомлений о новом комментарии
  def self.publish_comment(comment, except_client_id = nil)
    topic = comment.commentable
    return unless topic.respond_to? :section_id

    # уведомление в открытые топики
    data = { data: { comment_id: comment.id } }
    publish(data, ["/topic-#{topic.id}"], except_client_id)

    data[:data][:topic_id] = topic.id
    # уведомление в открытые разделы
    if topic.class == GroupComment
      publish(data, ["/group-#{topic.linked_id}"], except_client_id)
    else
      publish(data, ["/section-#{topic.section_id}"], except_client_id)
    end

    # уведомление в ленты
    publish(data, subscribed_channels(topic), except_client_id)
  end

  # отправка уведомлений о новом топике
  def self.publish_topic(topic, except_client_id = nil)
    data = { data: { topic_id: topic.id } }

    # уведомление в открытые разделы
    publish(data, ["/section-#{topic.section_id}"], except_client_id)

    # уведомление в ленты
    publish(data, subscribed_channels(topic), except_client_id)
  end

  # отправка произвольных уведомлений
  def self.publish(message, channels, except_client_id = nil)
    return if channels.empty?
    keys = channels.map { |c| @ns + "/channels#{c}" }

    $redis.sunion(*keys).each do |client_id|
      next if client_id == except_client_id
      message[:channel] = channels.size == 1 ? channels.first : "/#{BroadcastFeed}"

      $redis.rpush(@ns + "/clients/#{client_id}/messages", message.to_json)
      $redis.publish(@ns + '/notifications', client_id)
    end
  end

private
  def self.subscribed_channels(target)
    Subscription
      .where(target_id: target.id)
      .where(target_type: target.class.name)
      .select(:user_id)
      .map do |v|
        "/user-#{v.user_id}"
      end
  end
end
