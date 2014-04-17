class AnimeOnline::AdsPolicy

  def self.host_allowed? host
    host == AnimeOnlineDomain::HOST_PLAY
  end
end
