module ShikimoriDomain
  HOST = "shikimori.#{Rails.env.development? ? :dev : :org}"
  HOSTS = [HOST, "beta.#{HOST}"]
  HOSTS += ['localhost'] if Rails.env.development?

  def self.matches? request
    !AnimeOnlineDomain.matches?(request) && !MangaOnlineDomain.matches?(request)
  end
end
