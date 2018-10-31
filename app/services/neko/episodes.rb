class Neko::Episodes
  method_object :anime

  def call
    if @anime.anons?
      0
    elsif @anime.released?
      @anime.episodes
    else
      @anime.episodes_aired.zero? ? @anime.episodes : @anime.episodes_aired
    end
  end
end
