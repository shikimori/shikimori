# Публикация различных уведомлений через Faye
# FayePublisher.publish({ data: { comment_id: 2919 } }, ['/topic-77141'])
# FayePublisher.publish({ data: { comment_id: 2919, topic_id: 77141 } }, ['/section-1'])
class FayePublisher
  BroadcastFeed = 'myfeed'

  def initialize actor, publisher_faye_id = nil
    @namespace = ''
    @publisher_faye_id = publisher_faye_id
    @actor = actor
  end

  def publish trackable, event, channels=[]
    if trackable.kind_of? Comment
      publish_comment trackable, event, channels

    elsif trackable.kind_of? Entry
      publish_topic trackable, event, channels

    elsif trackable.kind_of? Message
      publish_message trackable, event, channels

    else
      publish_data trackable, event, channels
    end
  end

private
  # отправка уведомлений о новом комментарии
  def publish_comment comment, event, channels
    topic = comment.commentable

    # уведомление в открытые топики
    data = {
      event: "comment:#{event}",
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32),
      topic_id: topic.id,
      comment_id: comment.id
    }
    topic_type = comment.commentable_type == User.name ? 'user' : 'topic'
    mixed_channels = channels + subscribed_channels(topic) +
      ["#{@namespace}/#{topic_type}-#{topic.id}"]

    # уведомление в открытые разделы
    if topic.kind_of? GroupComment
      mixed_channels += ["#{@namespace}/group-#{topic.linked_id}"]
    elsif topic.respond_to? :section_id
      mixed_channels += ["#{@namespace}/section-#{topic.section_id}"]
    end

    publish_data data, event, mixed_channels
  end

  # отправка уведомлений о новом топике
  def publish_topic topic, event, channels
    data = {
      event: "topic:#{event}",
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32),
      topic_id: topic.id
    }

    mixed_channels = channels + subscribed_channels(topic) +
      ["#{@namespace}/section-#{topic.section_id}", "#{@namespace}/topic-#{topic.id}"]

    publish_data data, event, mixed_channels
  end

  # отправка уведомлений о новом топике
  def publish_message message, event, channels
    data = {
      event: "message:#{event}",
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32),
      message_id: message.id
    }

    mixed_channels = channels + ["#{@namespace}/dialog-#{[message.from_id, message.to_id].sort.join '-'}"]
    publish_data data, event, mixed_channels
  end

  # отправка произвольных уведомлений
  def publish_data data, event, channels
    return if channels.empty?
    run_event_machine
    channels = ["/#{BroadcastFeed}"] if channels.empty?

    channels.each do |channel|
      faye_client.publish channel, data.merge(token: config[:server_token], publisher_faye_id: @publisher_faye_id)
    end
  end

  def subscribed_channels target
    #Subscription
      #.where(target_id: target.id)
      #.where(target_type: target.class.name)
      #.select(:user_id)
      #.map do |v|
        #"/user-#{v.user_id}"
      #end
    []
  end

private
  def faye_client
    @faye_client ||= Faye::Client.new "http://localhost:9292#{config[:endpoint]}"
  end

  def config
    @config ||= YAML.load_file Rails.root.join 'config/faye.yml'
  end

  def run_event_machine
    Thread.new do
      EM.epoll
      EM.set_descriptor_table_size 100000
      EM.run
    end unless EM.reactor_running?
    Thread.pass until EM.reactor_running?
  end
end
