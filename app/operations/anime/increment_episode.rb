class Anime::IncrementEpisode
  method_object :anime

  def call
    @anime.update episodes_aired: @anime.episodes_aired + 1 unless @anime.released?
  end
end
