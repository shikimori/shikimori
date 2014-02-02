class AnimeOnlineDomain
  DOMAIN_COMMON = 'play'
  DOMAIN_ADULT = 'xplay'
  HOST_PLAY = "#{DOMAIN_COMMON}.shikimori.org"
  HOST_XPLAY = "#{DOMAIN_ADULT}.shikimori.org"
  HOST = HOST_PLAY
  HOSTS = [
    '0.0.0.0', '178.63.23.138', 'animeonline.dev', 'animeonline.production',
    'play.shikimori.dev', 'xplay.shikimori.dev', HOST_PLAY, HOST_XPLAY
  ]

  def self.matches? request
    HOSTS.include? request.host
  end

  def self.valid_host? anime, request
    if anime.adult?
      self.adult_host? request
    else
      request.host =~ /^#{DOMAIN_COMMON}\./
    end
  end

  def self.adult_host? request
    request.host =~ /^#{DOMAIN_ADULT}\./
  end

  def self.host anime
    if anime.adult?
      AnimeOnlineDomain::HOST_XPLAY
    else
      AnimeOnlineDomain::HOST_PLAY
    end
  end
end
