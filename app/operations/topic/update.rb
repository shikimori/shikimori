# frozen_string_literal: true

class Topic::Update
  method_object :model, :params, :faye

  def call
    if(TopicsHelper.valid_linked params[:linked_type])
      is_updated = @faye.update @model, @params
      Changelog::LogUpdate.call @model, @faye.actor if is_updated
      broadcast if is_updated && broadcast?
      is_updated
    else
      false
    end
  end

private

  def broadcast?
    Topic::BroadcastPolicy.new(model).required?
  end

  def broadcast
    Notifications::BroadcastTopic.perform_in 10.seconds, @model.id
  end
end
