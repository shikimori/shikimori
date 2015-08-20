module ShikimoriDomain
  HOST = "shikimori.#{Rails.env.development? ? :dev : :org}"
  HOSTS = Rails.env.development? ? [HOST, 'localhost'] : [HOST, "beta.#{HOST}"]

  RU_HOST = "shikimori.#{Rails.env.development? ? :dev : :org}"

  def self.matches? request
    !AnimeOnlineDomain.matches?(request) && !MangaOnlineDomain.matches?(request)
  end
end
