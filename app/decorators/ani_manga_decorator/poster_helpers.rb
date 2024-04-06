module AniMangaDecorator::PosterHelpers
  def poster
    return if rkn_banned? || rkn_banned_poster?

    if respond_to?(:genres_v2) && genres_v2.any?(&:temporarily_posters_disabled?)
      return super&.moderation_accepted? ? super : nil
    end

    super
  end
end
