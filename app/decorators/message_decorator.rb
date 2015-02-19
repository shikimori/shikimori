class MessageDecorator < BaseDecorator
  def image
    anime_related? ? anime.image.url(:x48) : from.avatar_url(48)
  end

  def image_2x
    anime_related? ? anime.image.url(:x96) : from.avatar_url(80)
  end

  def url
    if kind == MessageType::Episode
      linked.linked.decorate.url
    elsif MessagesQuery::NEWS_KINDS.include?(kind)
      h.topic_url linked
    else
      h.profile_url from
    end
  end

  def title
    anime_related? ? h.localized_name(anime) : from.nickname
  end

  def generated_news?
    linked.respond_to?(:generated_news?) && linked.generated_news?
  end

private
  def anime_related?
    MessageType::ANIME_RELATED.include? kind
  end

  def anime
    linked.linked
  end
end
