class AnimeOnline::AdsPolicy
  def self.show_ad? host, user=nil
    host_allowed?(host) && !(User::TrustedVideoUploaders - User::Admins).include?(user.try(:id))
  end

private
  def self.host_allowed? host
    host == AnimeOnlineDomain::HOST_PLAY
  end
end
