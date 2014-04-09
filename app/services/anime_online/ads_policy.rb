class AnimeOnline::AdsPolicy

  def self.host_allowed? host
    host == AnimeOnlineDomain::HOST_PLAY
  end

  def self.top_line_allowed? host, action_name
     self.host_allowed?(host) && action_name == 'show'
  end
end
