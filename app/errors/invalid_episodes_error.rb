class InvalidEpisodesError < ArgumentError
  vattr_initialize :errors

  def to_s
    "InvalidEpisodesError: #{errors.join('; ')}"
  end
end
