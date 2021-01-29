class MessageDecorator < BaseDecorator
  instance_cache :action_tag, :generate_body

  def broken?
    linked_type.present? && linked_id.present? && !linked
  end

  def image
    if anime_related?
      ImageUrlGenerator.instance.url anime, :x48
    elsif club_broadcast?
      ImageUrlGenerator.instance.url linked.commentable.linked, :x48
    else
      from.avatar_url 48
    end
  end

  def image_2x
    if anime_related?
      ImageUrlGenerator.instance.url anime, :x96
    elsif club_broadcast?
      ImageUrlGenerator.instance.url linked.commentable.linked, :x96
    else
      from.avatar_url 80
    end
  end

  def url # rubocop:disable AbcSize
    if kind == MessageType::EPISODE
      linked.linked.decorate.url
    elsif [MessageType::CONTEST_STARTED, MessageType::CONTEST_FINISHED].include? kind
      h.contest_url linked
    elsif club_broadcast?
      h.club_url(linked.commentable.linked) + "#comment-#{linked.id}"
    elsif Messages::Query::NEWS_KINDS.include?(kind) && linked
      UrlGenerator.instance.topic_url(linked)
    else
      h.profile_url from
    end
  end

  def title
    if anime_related?
      h.localized_name anime
    elsif club_broadcast?
      linked.commentable.linked.name
    else
      from.nickname
    end
  end

  def for_generated_news_topic?
    return false if linked_type.blank?
    return false unless linked.is_a?(Topic)

    Topic::TypePolicy.new(linked).generated_news_topic?
  end

  def club_broadcast?
    kind == MessageType::CLUB_BROADCAST
  end

  def action_tag
    if for_generated_news_topic?
      OpenStruct.new(
        type: linked.action,
        text: linked.action == 'episode' ?
          "#{linked.action_text} #{linked.value}" :
          linked.action_text
      )
    elsif club_broadcast?
      OpenStruct.new(
        type: 'broadcast',
        text: I18n.t('comments.comment.broadcast')
      )
    end
  end

  def generate_body
    Messages::GenerateBody.call object
  end

private

  def anime_related?
    MessageType::ANIME_RELATED.include? kind
  end

  def anime
    linked.linked
  end
end
