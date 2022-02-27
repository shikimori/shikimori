# The clas real-time publishes data via faye
# Examples:
#   FayePublisher.new(User.first, nil).publish_data({ topic_id: 367377, comment_id: 8069086, user_id: 1, event: 'comment:created', actor: 'morr', actor_avatar: 'https://kawai.shikimori.one/system/users/x16/1.png?1595714910', actor_avatar_2x: 'https://kawai.shikimori.one/system/users/x32/1.png?1595714910' }, ['/critique-1629', '/comment-8069086', '/topic-367377', '/forum-12/ru', '/forum-20/ru'])
#   FayeService.new(User.find(1), nil).convert_review(Comment.find(8069088), true)
class FayePublisher # rubocop:disable ClassLength
  BROADCAST_FEED = 'broadcast'

  def self.faye_url
    shiki_domain = UrlGenerator.instance.shiki_domain
    faye_host = Rails.application.secrets[:faye][:host].gsub('%DOMAIN%', shiki_domain)

    Shikimori::PROTOCOL + '://' +
      faye_host + Rails.application.secrets[:faye][:endpoint_path]
  end

  def initialize actor, publisher_faye_id = nil
    @publisher_faye_id = publisher_faye_id
    @actor = actor
  end

  def publish trackable, event, channels = []
    case trackable
      when Comment then publish_comment trackable, event, channels
      when Topic then publish_topic trackable, event, channels
      when Message then publish_message trackable, event, channels
      else publish_data trackable, channels
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

  def publish_comment comment, event, channels
    publish_data(
      actor_event_data(:comment, event,
        topic_id: comment.commentable_id,
        comment_id: comment.id,
        user_id: comment.user_id),
      comment_channels(comment, channels)
    )
  end

  def publish_review review, event, channels
    publish_data(
      actor_event_data(:review, event, review_id: review.id, user_id: review.user_id),
      review_channels(review, channels)
    )
  end

  def publish_topic topic, event, channels
    publish_data(
      actor_event_data(:topic, event, topic_id: topic.id, user_id: topic.user_id),
      topic_channels(topic, channels)
    )
  end

  def publish_message message, event, channels
    publish_data(
      actor_event_data(:message, event, message_id: message.id),
      dialog_channels(message, channels)
    )
  end

  def publish_mark comment, mark_kind, mark_value
    publish_data(
      actor_event_data(:comment, :marked,
        topic_id: comment.commentable_id,
        comment_id: comment.id,
        mark_kind: mark_kind,
        mark_value: mark_value),
      comment_channels(comment, [])
    )
  end

  def publish_achievements achievements_data, channels
    data = {
      event: 'achievements',
      achievements: achievements_data
    }

    publish_data data, channels
  end

  def publish_conversion old_entry, new_entry
    publish_data(
      actor_event_data(old_entry.class.name.downcase, :converted,
        "#{old_entry.class.name.downcase}_id": old_entry.id,
        "#{new_entry.class.name.downcase}_id": new_entry.id,
        topic_id: (old_entry.commentable_id if old_entry.is_a?(Comment))),
      old_entry.is_a?(Comment) ?
        comment_channels(old_entry, []) :
        review_channels(old_entry, [])
    )
  end

  def publish_data data, channels
    return if channels.empty?

    channels = ["/#{BROADCAST_FEED}"] if channels.empty?

    run_event_machine
    log data, channels

    channels.each { |channel| publish_to channel, data }
  rescue RuntimeError => e
    raise unless e.message.include?('eventmachine not initialized')
  end

private

  def publish_to channel, data
    faye_client.publish channel, data.merge(
      token: Rails.application.secrets.faye[:token],
      publisher_faye_id: @publisher_faye_id
    )
  end

  def actor_event_data type, event, data
    {
      **data,
      event: "#{type}:#{event}",
      actor: @actor.nickname,
      actor_avatar: @actor.decorate.avatar_url(16),
      actor_avatar_2x: @actor.decorate.avatar_url(32)
    }
  end

  def comment_channels comment, channels
    mixed_channels = channels + linked_channels(comment.commentable) +
      comment.faye_channels +
      ["/#{comment.commentable_type.downcase}-#{comment.commentable_id}"]

    # уведомление в открытые разделы для топиков
    topic = comment.commentable
    if topic.is_a? Topics::EntryTopics::ClubTopic
      mixed_channels += ["/club-#{topic.linked_id}"]
    elsif topic.respond_to? :forum_id
      mixed_channels += [forum_channel(topic.forum_id, topic.locale)]
    end

    mixed_channels
  end

  def review_channels review, channels
    channels + review.faye_channels
  end

  def topic_channels topic, channels
    channels +
      topic.faye_channels +
      linked_channels(topic) +
      [forum_channel(topic.forum_id, topic.locale)]
  end

  def linked_channels topic
    return [] unless topic.respond_to?(:linked_type) && topic.linked_type

    ["/#{topic.linked_type.downcase}-#{topic.linked_id}"]
  end

  def dialog_channels message, channels
    channels + ["/dialog-#{[message.from_id, message.to_id].sort.join '-'}"]
  end

  def forum_channel forum_id, locale
    "/forum-#{forum_id}/#{locale}"
  end

  def faye_client
    @faye_client ||= Faye::Client.new self.class.faye_url
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
    NamedLogger.faye_publisher.info "#{data.to_json} #{channels}" if Rails.env.development?
  end
end
