# Публикация различных уведомлений через Faye
# FayePublisher.publish({ data: { comment_id: 2919 } }, ['/topic-77141'])
# FayePublisher.publish({ data: { comment_id: 2919, topic_id: 77141 } }, ['/section-1'])
class FayePublisher
  BroadcastFeed = 'myfeed'

  def initialize actor, except_client_id = nil
    @namespace = ''
    @except_client_id = except_client_id
    @actor = actor
  end

  def publish object, event, channels=[]
    if object.kind_of? Comment
      publish_comment object, event, channels

    elsif object.kind_of? Entry
      publish_topic object, event, channels

    else
      publish_data object, event, channels
    end
  end

private
  # отправка уведомлений о новом комментарии
  def publish_comment comment, event, channels
    topic = comment.commentable
    return unless topic.respond_to? :section_id

    # уведомление в открытые топики
    data = { event: event, actor: @actor.nickname, actor_avatar: @actor.decorate.avatar_url(16), comment_id: comment.id }
    publish_data data, event, ["#{@namespace}/topic-#{topic.id}"]

    data[:topic_id] = topic.id
    # уведомление в открытые разделы
    if topic.kind_of? GroupComment
      publish_data data, event, ["#{@namespace}/group-#{topic.linked_id}"]
    else
      publish_data data, event, ["#{@namespace}/section-#{topic.section_id}"]
    end

    # уведомление в ленты
    publish_data data, event, channels + subscribed_channels(topic)
  end

  # отправка уведомлений о новом топике
  def publish_topic topic, event, channels
    data = { event: event, actor: @actor.nickname, actor_avatar: @actor.decorate.avatar_url(16), topic_id: topic.id }

    # уведомление в открытые разделы
    publish_data data, event, ["#{@namespace}/section-#{topic.section_id}"]

    # уведомление в ленты
    publish_data data, event, channels + subscribed_channels(topic)
  end

  # отправка произвольных уведомлений
  def publish_data data, event, channels
    return if channels.empty?
    run_event_machine
    channels = ["/#{BroadcastFeed}"] if channels.empty?

    channels.each do |channel|
      faye_client.publish channel, data.merge(token: config[:server_token])
    end

    #keys = channels.map { |c| "#{@namespace}/channels#{c}" }

    #$redis.sunion(*keys).each do |client_id|
      #next if client_id == @except_client_id
      #message = {
        #channel: channels.size == 1 ? channels.first : "/#{BroadcastFeed}",
        #data: data
      #}

      #$redis.rpush "#{@namespace}/clients/#{client_id}/messages", message.to_json
      #$redis.publish "#{@namespace}/notifications", client_id
    #end
  end

  def subscribed_channels target
    Subscription
      .where(target_id: target.id)
      .where(target_type: target.class.name)
      .select(:user_id)
      .map do |v|
        "/user-#{v.user_id}"
      end
  end

private
  def faye_client
    @faye_client ||= Faye::Client.new "http://localhost:9292#{config[:endpoint]}"
  end

  def config
    @config ||= YAML.load_file Rails.root.join 'config/faye.yml'
  end

  def run_event_machine
    Thread.new { EM.run } unless EM.reactor_running?
    Thread.pass until EM.reactor_running?
  end
end
