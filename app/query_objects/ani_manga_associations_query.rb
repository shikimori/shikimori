require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class AniMangaAssociationsQuery
  def fetch
    Rails.cache.fetch('genres_studios_publishers', expires_in: 30.minutes) do
      [Genre.order(:position).to_a, Studio.all.to_a, Publisher.all.to_a]
    end
  end
end
