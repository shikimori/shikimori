class AnimeOnline::AdsPolicy
  def self.is_viewed? host, user=nil
    #host_allowed?(host) && !(User::TrustedVideoUploaders - User::Admins).include?(user.try(:id))
    false
  end

private
  def self.host_allowed? host
    host == AnimeOnlineDomain::HOST_PLAY
  end
end
