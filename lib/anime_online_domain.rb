class AnimeOnlineDomain
  HOST = '178.63.23.138'
  HOSTS = ['0.0.0.0', 'animeonline.dev', 'animeonline.production', HOST]

  def self.matches? request
    HOSTS.include? request.host
  end
end
