class Anime::IncrementEpisode
  method_object %i[anime! user]

  def call
    return if @anime.released?

    if user
      Versioneers::FieldsVersioneer
        .new(@anime)
        .postmoderate({ episodes_aired: @anime.episodes_aired + 1 }, @user)
    else
      @anime.update episodes_aired: @anime.episodes_aired + 1
    end
  end
end
