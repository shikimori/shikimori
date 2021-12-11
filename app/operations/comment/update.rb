# frozen_string_literal: true

class Comment::Update
  method_object :model, :params, :faye

  def call
    is_updated = @faye.update @model, @params
    Changelog::LogUpdate.call @model, @faye.actor if is_updated
    is_updated
  end
end
