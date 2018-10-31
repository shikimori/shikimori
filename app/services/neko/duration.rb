class Neko::Duration
  method_object :anime

  def call
    @anime.duration * Neko::Episodes.call(@anime)
  end
end
