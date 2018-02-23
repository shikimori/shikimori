module ShikimoriDomain
  RU_HOSTS = %w[shikimori.org] + (
    Rails.env.development? ? %w[shikimori.test ru.shikimori.test localhost] : []
  )
  EN_HOSTS = %w[shikimori.one] + (
    Rails.env.development? ? %w[en.shikimori.test] : []
  )

  HOSTS = RU_HOSTS + EN_HOSTS

  def self.matches? request
    !AnimeOnlineDomain.matches?(request) &&
      !MangaOnlineDomain.matches?(request)
  end
end
