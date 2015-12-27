class ForumForList < SimpleDelegator
  include Draper::ViewHelpers

  attr_reader :is_special

  def initialize forum, is_special
    super forum
    @is_special = is_special
  end

  def url
    h.forum_topics_path object
  end

  def size
    return nil unless is_special

    @size ||= TopicsQuery
      .new(current_user)
      .by_forum(object)
      .where('generated = false or (generated = true and comments_count > 0)')
      .size
  end

private

  def current_user
    h.current_user rescue NoMethodError
  end
end
