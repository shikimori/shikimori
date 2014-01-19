class AnimeOnlineDomain
  HOST = 'play.shikimori.org'
  HOSTS = ['0.0.0.0', '178.63.23.138', 'animeonline.dev', 'animeonline.production', 'play.shikimori.dev', HOST]

  def self.matches? request
    HOSTS.include? request.host
  end
end
