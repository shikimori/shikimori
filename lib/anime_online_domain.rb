class AnimeOnlineDomain
  IP = '1.2.3.4'
  DOMAINS = ['animeonline.dev', 'animeonline.production']

  def self.matches? request
    DOMAINS.include? request.host
  end
end
