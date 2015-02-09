module ShikimoriDomain
  HOST = "shikimori.#{Rails.env.development? ? :dev : :org}"
  HOSTS = Rails.env.development? ? [HOST, 'localhost'] : [HOST, "beta.#{HOST}"]

  def self.matches? request
    !AnimeOnlineDomain.matches?(request) && !MangaOnlineDomain.matches?(request)
  end
end
