# frozen_string_literal: true

class Comment::Update
  method_object %i[comment! params! faye!]

  def call
    @faye.update @comment, @params
  end
end
