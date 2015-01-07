# TODO: выпилить anime_statuses, :manga_statuses
class UserProfileSerializer < UserSerializer
  attributes :name, :sex, :full_years, :last_online, :last_online_at, :website, :location, :last_online_at
  attributes :banned?, :about, :about_html, :common_info, :last_online, :show_comments?

  attributes :stats

  def website
    (object.object.website || '').sub(/^https?:\/\//, '')
  end

  def stats
    {
      statuses: object.stats.statuses,
      scores: {
        anime: object.stats.scores(:anime),
        manga: object.stats.scores(:manga)
      },
      types: {
        anime: object.stats.types(:anime),
        manga: object.stats.types(:manga)
      },
      ratings: {
        anime: object.stats.ratings(:anime),
        manga: object.stats.ratings(:manga)
      },
      has_anime?: object.stats.anime?,
      has_manga?: object.stats.manga?,
      genres: object.stats.genres,
      studios: object.stats.studios,
      publishers: object.stats.publishers,
      activity: object.stats.activity
    }
  end
end
