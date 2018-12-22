# TODO: выпилить anime_statuses, :manga_statuses
class UserProfileSerializer < UserSerializer
  attributes :name, :sex, :full_years, :last_online, :last_online_at,
    :website, :location, :last_online_at, :banned, :about, :about_html,
    :common_info, :last_online, :show_comments, :in_friends, :is_ignored,
    :stats, :style_id

  delegate :common_info, :full_years, to: :view

  def last_online_at
    object.exact_last_online_at
  end

  def website
    (object.object.website || '').sub(%r{^https?://}, '')
  end

  def stats
    {
      statuses: object.stats.statuses,
      full_statuses: object.stats.full_statuses,
      scores: {
        anime: object.stats.scores(:anime),
        manga: object.stats.scores(:manga)
      },
      types: {
        anime: object.stats.kinds(:anime),
        manga: object.stats.kinds(:manga)
      },
      ratings: {
        anime: object.stats.anime_ratings
      },
      has_anime?: object.stats.anime?,
      has_manga?: object.stats.manga?,
      genres: [], # object.stats.genres,
      studios: [], # object.stats.studios,
      publishers: [], # object.stats.publishers,
      activity: object.stats.activity(26)
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
