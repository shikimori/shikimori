module MangaOnlineDomain
  DOMAIN_COMMON = 'manga'
  HOST_MANGA = "#{DOMAIN_COMMON}.shikimori.#{Rails.env.development? ? :dev : :org}"
  HOSTS = [
    '0.0.0.0', '178.63.23.138', HOST_MANGA
  ]

  def self.matches? request
    HOSTS.include? request.host
  end
end
