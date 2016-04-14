# frozen_string_literal: true

class NoTopic < NullObject
  rattr_initialize :linked

  def comments
    Comment.none
  end

  def comments_count
    0
  end

  def summaries_count
    0
  end

private

  def base_klass
    Topic
  end
end
