class MissingEpisodeError < ArgumentError
  pattr_initialize :episode, :anime_id

  def to_s
    "Missing episode #{@episode} for anime #{@anime_id}"
  end
end
