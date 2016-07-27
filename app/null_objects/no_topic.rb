# frozen_string_literal: true

class NoTopic < NullObject
  rattr_initialize :linked

  def comments
    Comment.none
  end

  def comments_count
    0
  end

  def comments
    Comment.none
  end

private

  def base_klass
    Topic
  end
end
