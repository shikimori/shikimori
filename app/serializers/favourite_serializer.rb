class FavouriteSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :russian, :image, :url

  def image
    object.image.url(:x64)
  end

  def url
    case object
      when Anime then anime_path object
      when Manga then manga_path object
      when Character then character_path object
      when Person then person_path object
    end
  end
end
