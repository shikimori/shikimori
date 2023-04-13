module ShikimoriDomain
  RU_HOSTS = %w[shikimori.me shikimori.one shikimori.org] + (
    Rails.env.development? ? %w[shikimori.local shiki.local localhost] : []
  )
  EN_HOSTS = %w[] # + (
    # Rails.env.development? ? %w[en.shikimori.local] : []
  # )
  BANNED_HOST = 'shikimori.org'
  CLEAN_HOST = 'shikimori.one'

  HOSTS = RU_HOSTS + EN_HOSTS

  PROPER_HOST = Rails.env.production? ?
    'shikimori.me' :
    'shikimori.local'

  def self.matches? request
    HOSTS.include? request.host
  end
end
