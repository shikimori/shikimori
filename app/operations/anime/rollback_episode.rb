class Anime::RollbackEpisode
  method_object %i[anime! episode! user]

  def call
    return if @anime.episodes_aired < @episode || @anime.episodes_aired.zero?

    @anime
      .episode_notifications
      .where('episode >= ?', @episode)
      .destroy_all

    if user
      Versioneers::FieldsVersioneer
        .new(@anime)
        .postmoderate({ episodes_aired: @episode - 1 }, @user)
    else
      @anime.update episodes_aired: @episode - 1
    end
  end
end
