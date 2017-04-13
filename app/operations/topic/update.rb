# frozen_string_literal: true

class Topic::Update < ServiceObjectBase
  pattr_initialize :model, :params, :faye

  def call
    is_updated = @model.class.wo_timestamp { @faye.update @model, @params }
    @model.update commented_at: Time.zone.now if is_updated
    is_updated
  end
end
