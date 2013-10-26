require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class AniMangaAssociationsQuery
  def fetch
    Rails.cache.fetch('genres_studios_publishers', expires_in: 30.minutes) do
      [Genre.order(:position).all, Studio.all, Publisher.all]
    end
  end
end
