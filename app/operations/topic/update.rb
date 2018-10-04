# frozen_string_literal: true

class Topic::Update
  method_object %i[topic! params! faye!]

  def call
    is_updated = @topic.class.wo_timestamp do
      @faye.update @topic, @params
    end

    if is_updated
      @topic.update commented_at: Time.zone.now
    end

    is_updated
  end
end
