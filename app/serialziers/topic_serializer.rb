class TopicSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :html_body, :viewed?, :created_at, :comments_count, :section, :user, :type, :linked_id, :linked_type, :linked

  def section
    SectionSerializer.new object.section
  end

  def user
    UserSerializer.new object.user
  end

  def body
    object.text
  end

  def html_body
    BbCodeFormatter.instance.format_comment body
  end

  def linked
    case object.linked_type
      when Anime.name then AnimeSerializer.new object.linked
      when Manga.name then MangaSerializer.new object.linked
      when Character.name then CharacterSerializer.new object.linked
      when Group.name then GroupSerializer.new object.linked
      when Review.name then ReviewSerializer.new object.linked
    end
  end
end
