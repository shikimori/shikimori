module ShikimoriDomain
  RU_HOSTS = %w[shikimori.org] + (
    Rails.env.development? ? %w[shikimori.dev ru.shikimori.dev localhost] : []
  )
  EN_HOSTS = %w[shikimori.one] + (
    Rails.env.development? ? %w[en.shikimori.dev] : []
  )

  HOSTS = RU_HOSTS + EN_HOSTS

  def self.matches? request
    !AnimeOnlineDomain.matches?(request) &&
      !MangaOnlineDomain.matches?(request)
  end
end
