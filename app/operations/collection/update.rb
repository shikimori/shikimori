# frozen_string_literal: true

class Collection::Update < ServiceObjectBase
  pattr_initialize :model, :params

  def call
    @model.update @params
    @model
  end
end
