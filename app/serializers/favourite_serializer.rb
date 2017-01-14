class FavouriteSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url

  def image
    object.image.url(:x64)
  end

  def url
    case object
      when Anime then UrlGenerator.instance.anime_path object
      when Manga then UrlGenerator.instance.manga_path object
      when Character then UrlGenerator.instance.character_path object
      when Person then UrlGenerator.instance.person_path object
    end
  end
end
