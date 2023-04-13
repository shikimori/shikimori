module ShikimoriDomain
  RU_HOSTS = %w[shikimori.me shikimori.one shikimori.org] + (
    Rails.env.development? ? %w[shikimori.local shiki.local localhost] : []
  )
  EN_HOSTS = %w[] # + (
    # Rails.env.development? ? %w[en.shikimori.local] : []
  # )
  BANNED_HOST = 'shikimori.org'
  CLEAN_HOST = 'shikimori.one'
  NEW_HOST = 'shikimori.me'

  HOSTS = RU_HOSTS + EN_HOSTS

  PROPER_HOST = Rails.env.production? ?
    NEW_HOST :
    'shikimori.local'

  def self.matches? request
    HOSTS.include? request.host
  end
end
