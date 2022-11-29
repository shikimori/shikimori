# frozen_string_literal: true

class Critique::Update
  method_object :model, :params, :actor

  def call
    is_updated = @model.update @params.merge(changed_at: Time.zone.now)
    Changelog::LogUpdate.call @model, @actor if is_updated
    is_updated
  end
end
