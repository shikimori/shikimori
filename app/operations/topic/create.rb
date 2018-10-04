# frozen_string_literal: true

class Topic::Create
  method_object %i[faye! params! locale!]

  def call
    topic = Topic.new @params.merge(locale: @locale)
    broadcast topic if @faye.create topic
    topic
  end

private

  def broadcast topic
  end
end
