class MessageDecorator < BaseDecorator
  instance_cache :action_tag, :generate_body

  def image
    if anime_related?
      anime.image.url :x48
    elsif kind == MessageType::ClubBroadcast
      ImageUrlGenerator.instance.url linked.commentable.linked, :x48
    else
      from.avatar_url 48
    end
  end

  def image_2x
    if anime_related?
      anime.image.url :x96
    elsif kind == MessageType::ClubBroadcast
      ImageUrlGenerator.instance.url linked.commentable.linked, :x96
    else
      from.avatar_url 80
    end
  end

  def url
    if kind == MessageType::Episode
      linked.linked.decorate.url
    elsif kind == MessageType::ContestFinished
      h.contest_url linked
    elsif kind == MessageType::ClubBroadcast
      h.club_url(linked.commentable.linked) + "#comment-#{linked.id}"
    elsif MessagesQuery::NEWS_KINDS.include?(kind)
      UrlGenerator.instance.topic_url(linked)
    else
      h.profile_url from
    end
  end

  def title
    if anime_related?
      h.localized_name anime
    elsif kind == MessageType::ClubBroadcast
      linked.commentable.linked.name
    else
      from.nickname
    end
  end

  def for_generated_news_topic?
    return false unless linked.is_a?(Topic)
    Topic::TypePolicy.new(linked).generated_news_topic?
  end

  def action_tag
    OpenStruct.new(
      type: linked.action,
      text: linked.action == 'episode' ?
        "#{linked.action_text} #{linked.value}" :
        linked.action_text
    ) if for_generated_news_topic?
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
