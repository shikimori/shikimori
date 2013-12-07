class AnimeOnlineDomain
  HOSTS = ['0.0.0.0', 'animeonline.dev', 'animeonline.production', '178.63.23.138']

  def self.matches? request
    HOSTS.include? request.host
  end
end
