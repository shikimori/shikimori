module ShikimoriDomain
  RU_HOSTS = %w[shikimori.org] + (
    Rails.env.development? ? %w[shikimori.local ru.shikimori.local localhost] : []
  )
  EN_HOSTS = %w[shikimori.one] + (
    Rails.env.development? ? %w[en.shikimori.local] : []
  )

  HOSTS = RU_HOSTS + EN_HOSTS

  def self.matches? request
    !AnimeOnlineDomain.matches?(request)
  end
end
