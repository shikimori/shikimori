module AniMangaDecorator::PosterHelpers
  def poster
    return if rkn_banned? || rkn_banned_poster?
    return if poster_disabled_by_genres?

    # if poster_disabled_by_genres?
    #   return super&.moderation_accepted? ? super : nil
    # end

    super
  end

  def poster_disabled_by_genres?
    respond_to?(:genres_v2) && genres_v2.any?(&:temporarily_posters_disabled?)
  end
end
