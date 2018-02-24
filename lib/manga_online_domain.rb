module MangaOnlineDomain
  DOMAIN_COMMON = 'manga'
  HOST_MANGA = "#{DOMAIN_COMMON}.shikimori.#{Rails.env.development? ? :test : :org}"
  HOSTS = [HOST_MANGA]

  def self.matches? request
    HOSTS.include? request.host
  end
end
