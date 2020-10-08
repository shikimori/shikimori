class BbCodes::Quotes::QuoteableToBbcode
  include Singleton

  def call meta
    if meta[:comment_id]
      comment_to_html meta
    elsif meta[:message_id]
      message_to_html meta
    elsif meta[:topic_id]
      topic_to_html meta
    else
      user_to_html meta
    end
  end

private

  def comment_to_html meta
    "[comment=#{meta[:comment_id]} quote]"
  end

  def message_to_html meta
    "[message=#{meta[:message_id]} quote]"
  end

  def topic_to_html meta
    "[topic=#{meta[:topic_id]} quote]#{meta[:nickname]}[/topic]"
  end

  def user_to_html meta
    "[user]#{meta[:nickname]}[/user]"
  end
end
