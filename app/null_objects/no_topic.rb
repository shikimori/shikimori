# frozen_string_literal: true

class NoTopic < NullObject
  rattr_initialize %i[id linked]

  def comments
    Comment.none
  end

  def comments_count
    0
  end

  private

  def base_klass
    Topic
  end
end
