require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class AniMangaAssociationsQuery
  def fetch klass
    Rails.cache.fetch([:genres_studios_publishers, klass], expires_in: 30.minutes) do
      [
        Genre.order(:position).where(kind: klass.name.downcase).to_a,
        Studio.all.to_a,
        Publisher.all.to_a
      ]
    end
  end
end
