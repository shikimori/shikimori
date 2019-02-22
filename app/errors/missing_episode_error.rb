class MissingEpisodeError < ArgumentError
  vattr_initialize :anime_id, :episode

  def to_s
    "Missing episode #{@episode} for anime #{@anime_id}"
  end
end
