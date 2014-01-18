class AnimeOnlineDomain
  HOST = 'play.shikimori.org'
  HOSTS = ['0.0.0.0', 'animeonline.dev', 'animeonline.production', HOST]

  def self.matches? request
    HOSTS.include? request.host
  end
end
