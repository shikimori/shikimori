# frozen_string_literal: true

class Topic::Create < ServiceObjectBase
  pattr_initialize :faye, :params, :locale

  def call
    topic = Topic.new @params.merge(locale: @locale)
    @faye.create topic
    topic
  end
end
