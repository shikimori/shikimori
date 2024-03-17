module AniMangaDecorator::PosterHelpers
  def poster
    return if rkn_banned? || rkn_banned_poster?
    return if respond_to?(:genres_v2) && genres_v2.any?(&:temporarily_posters_disabled?)

    super
  end
end
