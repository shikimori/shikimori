module ShikimoriDomain
  RU_HOSTS = %w(shikimori.org shikimori.dev ru.shikimori.dev localhost)
  EN_HOSTS = %w(shikimori.one en.shikimori.dev)

  HOSTS = RU_HOSTS + EN_HOSTS

  PUBLIC_HOSTS = HOSTS.select { |host| !host.match? /\.dev$/ } - %w[localhost]

  def self.matches? request
    !AnimeOnlineDomain.matches?(request) &&
      !MangaOnlineDomain.matches?(request)
  end
end
