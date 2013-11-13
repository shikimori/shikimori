class AnimeOnlineDomain
  HOSTS = ['0.0.0.0', 'animeonline.dev', 'animeonline.production'].freeze

  def self.matches? request
    HOSTS.include? request.host
  end
end

class ShikimoriDomain
  def self.matches? request
    !AnimeOnlineDomain.matches?(request)
  end
end
