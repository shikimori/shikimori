class AnimeVideoDomain
  IP = '1.2.3.4'
  DOMAINS = ['animevideo.dev', 'animevideo.production']

  def self.matches? request
    DOMAINS.include? request.host
  end
end
