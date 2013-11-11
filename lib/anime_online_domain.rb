class AnimeOnlineDomain
  IP = '1.2.3.4'
  DOMAINS = ['animeonline.dev', 'animeonline.production'].freeze

  def self.matches? request
    DOMAINS.include? request.host#and request.parameters[:controller] =~ /^anime_online\/.*/
  end
end

class ShikimoriDomain
  def self.matches? request
    !AnimeOnlineDomain.matches?(request)
  end
end
