class AnimeOnline::SameVideos
  method_object %i[anime_video_id! anime_id! episode! kind!]

  def call
    AnimeVideo
      .where(
        anime_id: @anime_id,
        episode: @episode,
        kind: @kind
      )
      .where.not(id: @anime_video_id)
      .available
  end
end
