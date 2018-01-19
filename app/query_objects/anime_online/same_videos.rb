class AnimeOnline::SameVideos
  method_object :anime_video

  def call
    AnimeVideo
      .where(
        anime_id: @anime_video.anime_id,
        episode: @anime_video.episode,
        kind: @anime_video.kind
      )
      .where.not(id: @anime_video.id)
      .available
  end
end
