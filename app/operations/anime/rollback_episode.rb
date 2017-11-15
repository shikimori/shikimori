class Anime::RollbackEpisode
  method_object :anime, :episode

  def call
    if @anime.episodes_aired >= @episode
      @anime.update episodes_aired: @episode - 1
    end
    @anime.episode_notifications.where('episode >= ?', @episode).destroy_all
  end
end
