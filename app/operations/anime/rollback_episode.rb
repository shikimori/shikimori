class Anime::RollbackEpisode
  method_object %i[anime! episode! user]

  def call
    return if @anime.episodes_aired < @episode || @anime.episodes_aired.zero?

    @anime
      .episode_notifications
      .where('episode >= ?', @episode)
      .destroy_all

    if user
      create_version
    else
      update_anime
    end
  end

private

  def create_version
    Versioneers::FieldsVersioneer
      .new(@anime)
      .postmoderate({ episodes_aired: @episode - 1 }, @user)
  end

  def update_anime
    @anime.update episodes_aired: new_episodes_aired
  end

  def new_episodes_aired
    [@episode - 1, 0].max
  end
end
