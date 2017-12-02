class EpisodeNotification::Create
  method_object %i[anime_id! episode! kind!]

  def call
    EpisodeNotification
      .find_or_initialize_by(anime_id: @anime_id, episode: @episode)
      .update("is_#{@kind}" => true)
  end
end
