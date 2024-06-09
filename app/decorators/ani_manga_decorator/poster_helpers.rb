module AniMangaDecorator::PosterHelpers
  def poster
    # return if apply_poster_moderation?
    return if rkn_banned? || rkn_banned_poster?
    return if apply_poster_moderation? && super&.moderation_rejected?

    super
  end

  def apply_poster_moderation?
    respond_to?(:genres_v2) && genres_v2.any?(&:temporarily_posters_disabled?)
  end
end
