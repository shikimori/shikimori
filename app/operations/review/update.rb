# frozen_string_literal: true

class Review::Update < ServiceObjectBase
  pattr_initialize :model, :params

  def call
    @model.update update_params
    @model
  end

private

  def update_params
    @params.merge changed_at: Time.zone.now
  end
end
