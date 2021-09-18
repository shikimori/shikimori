class CritiqueSerializer < ActiveModel::Serializer
  attributes :id, :target, :user, :votes_count, :votes_for, :body, :html_body,
    :overall, :storyline, :music, :characters, :animation, :created_at

  def body
    object.text
  end

  def html_body
    Rails.cache.fetch CacheHelper.keys(object, :body), expires_in: 2.weeks do
      BbCodes::Text.call object.text
    end
  end

  def user
    UserSerializer.new object.user
  end

  def target
    case object.target_type
      when Anime.name then AnimeSerializer.new(object.target)
      when Manga.name then MangaSerializer.new(object.target)
    end
  end

  def votes_for
    object.cached_votes_up
  end

  def votes_count
    object.cached_votes_up + object.cached_votes_down
  end
end
