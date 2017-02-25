module ShikimoriDomain
  RU_HOSTS = %w(locahost shikimori.dev ru.shikimori.dev shikimori.org)
  EN_HOSTS = %w(en.shikimori.dev shikimori.one)

  HOSTS = RU_HOSTS + EN_HOSTS

  def self.matches? request
    !AnimeOnlineDomain.matches?(request) &&
      !MangaOnlineDomain.matches?(request)
  end
end
