class AnimeOnlineDomain
  HOSTS = ['0.0.0.0', 'animeonline.dev', 'animeonline.production'].freeze

  def self.matches? request
    HOSTS.include? request.host
  end
end

class ShikimoriDomain
  HOSTS = ['dev.shikimori.de', 'dev.shikimori.org', 'shikimori.dev', 'shikimori.org', 'shikimori.de'].freeze

  def self.matches? request
    !AnimeOnlineDomain.matches? request
  end
end
