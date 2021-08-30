# TODO: выпилить anime_statuses, :manga_statuses
class UserProfileSerializer < UserSerializer
  attributes :name, :sex, :full_years, :last_online, :last_online_at,
    :website, :location, :last_online_at, :banned, :about, :about_html,
    :common_info, :last_online, :show_comments, :in_friends, :is_ignored,
    :stats, :style_id

  delegate :common_info, :full_years, to: :view

  def name
    nil
  end

  def location
    nil
  end

  def last_online_at
    object.exact_last_online_at
  end

  def website
    (object.object.website || '').sub(%r{^https?://}, '')
  end

  def stats
    {
      statuses: object.list_stats.statuses,
      full_statuses: object.list_stats.full_statuses,
      scores: {
        anime: object.list_stats.scores(:anime),
        manga: object.list_stats.scores(:manga)
      },
      types: {
        anime: object.list_stats.kinds(:anime),
        manga: object.list_stats.kinds(:manga)
      },
      ratings: {
        anime: object.list_stats.anime_ratings
      },
      has_anime?: object.list_stats.anime?,
      has_manga?: object.list_stats.manga?,
      genres: [], # object.list_stats.genres,
      studios: [], # object.list_stats.studios,
      publishers: [], # object.list_stats.publishers,
      activity: object.list_stats.activity(26)
    }
  end

  def in_friends
    object.is_friended?
  end

  def is_ignored # rubocop:disable PredicateName
    view.ignored?
  end

  def about_html
    view.about_html&.gsub(%r{(?<!:)//(?=\w)}, 'http://') || ''
  end

  def banned
    object.banned?
  end

  def show_comments
    view.show_comments?
  end

private

  def view
    @view ||= Profiles::View.new object
  end
end
