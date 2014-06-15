class AnimeOnline::AdsPolicy
  def self.is_viewed? host, user=nil
    host_allowed?(host) && !User::TrustedVideoUploaders.include?(user.try(:id))
  end

private
  def self.host_allowed? host
    host == AnimeOnlineDomain::HOST_PLAY
  end
end
