class MessageDecorator < BaseDecorator
  def image
    anime_related? ? anime.image.url(:x48) : from.avatar_url(48)
  end

  def image_2x
    anime_related? ? anime.image.url(:x96) : from.avatar_url(80)
  end

  def url
    h.profile_url(from)
  end

  def title
    anime_related? ? h.localized_name(anime) : from.nickname
  end

private
  def anime_related?
    MessageType::ANIME_RELATED.include? kind
  end

  def anime
    linked.linked
  end
end
