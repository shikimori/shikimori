class Anime::RollbackEpisode
  method_object :anime, :episode

  def call
    @anime.update episodes_aired: @episode - 1 if @anime.episodes_aired >= @episode
    @anime.episode_notifications.where('episode >= ?', @episode).destroy_all
  end
end
