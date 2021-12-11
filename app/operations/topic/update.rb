# frozen_string_literal: true

class Topic::Update
  method_object %i[topic! params! faye!]

  def call
    is_updated = update_topic
    changelog if is_updated
    broadcast @topic if is_updated && broadcast?(@topic)
    is_updated
  end

private

  def update_topic
    @faye.update @topic, @params
  end

  def broadcast? topic
    Topic::BroadcastPolicy.new(topic).required?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_in 10.seconds, topic.id
  end

  def changelog
    NamedLogger.changelog.info(
      user_id: @faye.actor&.id,
      action: :update,
      topic: { 'id' => @topic.id },
      changes: @topic.saved_changes.except('updated_at')
    )
  end
end
