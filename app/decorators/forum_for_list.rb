class ForumForList < SimpleDelegator
  include Draper::ViewHelpers

  attr_reader :is_special, :size

  def initialize forum, is_special, size
    super forum

    @is_special = is_special
    @size = size
  end

  def url
    h.forum_topics_url self
  end
end
