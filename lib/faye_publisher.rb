# Публикация различных уведомлений через Faye
# FayePublisher.new(User.first, nil).publish({ data: { comment_id: 999999999, topic_id: 79981 } }, ['/topic-79981'])
# rubocop:disable ClassLength
class FayePublisher
  BROADCAST_FEED = 'myfeed'

  def initialize actor, publisher_faye_id = nil
    @publisher_faye_id = publisher_faye_id
    @actor = actor
  end

  def publish trackable, event, channels = []
    if trackable.is_a? Comment
      publish_comment trackable, event, channels

    elsif trackable.is_a? Topic
      publish_topic trackable, event, channels

    elsif trackable.is_a? Message
      publish_message trackable, event, channels

    else
      publish_data trackable, channels
    end
  end

  def publish_marks comment_ids, mark_kind, mark_value
    Comment
      .includes(:commentable)
      .where(id: comment_ids[0..100])
      .order(id: :desc)
      .each { |v| publish_mark v, mark_kind, mark_value }
  end

  def publish_replies comment, replies_html
    data = {
      event: 'comment:set_replies',
      topic_id: comment.commentable_id,
      comment_id: comment.id,
      replies_html: replies_html
    }
    publish_data data, comment_channels(comment, [])
  end

  # отправка уведомлений о новом комментарии
  def publish_comment comment, event, channels
    # уведомление в открытые топики
    data = {
      event: "comment:#{event}",
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32),
      topic_id: comment.commentable_id,
      comment_id: comment.id,
      user_id: comment.user_id
    }
    publish_data data, comment_channels(comment, channels)
  end

  # отправка уведомлений о новом топике
  def publish_topic topic, event, channels
    data = {
      event: "topic:#{event}",
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32),
      topic_id: topic.id,
      user_id: topic.user_id
    }

    publish_data data, topic_channels(topic, channels)
  end

  # отправка уведомлений о новом сообщении
  def publish_message message, event, channels
    data = {
      event: "message:#{event}",
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32),
      message_id: message.id
    }

    publish_data data, dialog_channels(message, channels)
  end

  # rubocop:disable MethodLength
  def publish_mark comment, mark_kind, mark_value
    # уведомление в открытые топики
    data = {
      event: 'comment:marked',
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32),
      topic_id: comment.commentable_id,
      comment_id: comment.id,
      mark_kind: mark_kind,
      mark_value: mark_value
    }

    publish_data data, comment_channels(comment, [])
  end
  # rubocop:enable MethodLength

  def publish_data data, channels
    return if channels.empty?

    channels = ["/#{BROADCAST_FEED}"] if channels.empty?

    run_event_machine
    log data, channels

    channels.each { |channel| publish_to channel, data }
  rescue RuntimeError => e
    raise unless e.message.match?(/eventmachine not initialized/)
  end

private

  def publish_to channel, data
    faye_client.publish channel, data.merge(
      token: config[:server_token],
      publisher_faye_id: @publisher_faye_id
    )
  end

  # rubocop:disable MethodLength
  # rubocop:disable AbcSize
  def comment_channels comment, channels
    topic = comment.commentable
    topic_type = comment.commentable_type == User.name ? 'user' : 'topic'

    mixed_channels = channels +
      subscribed_channels(topic) + linked_channels(topic) +
      ["/#{topic_type}-#{topic.id}"]

    # уведомление в открытые разделы
    if topic.is_a? Topics::EntryTopics::ClubTopic
      mixed_channels += ["/club-#{topic.linked_id}"]
    elsif topic.respond_to? :forum_id
      mixed_channels += [forum_channel(topic.forum_id, topic.locale)]
    end

    mixed_channels
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength

  def topic_channels topic, channels
    channels +
      subscribed_channels(topic) + linked_channels(topic) +
      [forum_channel(topic.forum_id, topic.locale), "/topic-#{topic.id}"]
  end

  def linked_channels topic
    return [] unless topic.respond_to?(:linked_type) && topic.linked_type
    ["/#{topic.linked_type.downcase}-#{topic.linked_id}"]
  end

  def dialog_channels message
    channels + ["/dialog-#{[message.from_id, message.to_id].sort.join '-'}"]
  end

  def subscribed_channels _target
    # Subscription
      # .where(target_id: target.id)
      # .where(target_type: target.class.name)
      # .select(:user_id)
      # .map do |v|
        # "/user-#{v.user_id}"
      # end
    []
  end

  def forum_channel forum_id, locale
    "/forum-#{forum_id}/#{locale}"
  end

  def faye_client
    @faye_client ||= Faye::Client.new(
      "http://127.0.0.1:9292#{config[:endpoint]}"
    )
  end

  def config
    @config ||= YAML.load_file "#{Rails.root}/config/faye.yml"
  end

  def run_event_machine
    unless EM.reactor_running?
      Thread.new do
        EM.epoll
        EM.set_descriptor_table_size 100_000
        EM.run
      end
    end
    Thread.pass until EM.reactor_running?
  end

  def log data, channels
    if Rails.env.development?
      NamedLogger.faye_publisher.info "#{data.to_json} #{channels}"
    end
  end
end
