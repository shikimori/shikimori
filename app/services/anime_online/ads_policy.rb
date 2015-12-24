class AnimeOnline::AdsPolicy
  def self.show_ad? host, user=nil, anime=nil
    host_allowed?(host) &&
      !(User::TRUSTED_VIDEO_UPLOADERS - User::ADMINS).include?(user.try(:id)) &&
      (!anime || !Copyright::IVI_RU_COPYRIGHTED.include?(anime.id))
  end

private
  def self.host_allowed? host
    host == AnimeOnlineDomain::HOST_PLAY
  end
end
