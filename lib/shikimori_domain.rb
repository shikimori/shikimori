module ShikimoriDomain
  FOREVER_BANNED_HOST = 'shikimori.org'
  OLD_HOST = 'shikimori.me'
  NEW_HOST = 'shikimori.one'

  HOSTS = [NEW_HOST, OLD_HOST, FOREVER_BANNED_HOST] + (
    Rails.env.development? ? %w[shikimori.local shiki.local localhost] : []
  )

  BANNED_HOSTS = [FOREVER_BANNED_HOST, OLD_HOST]

  PROPER_HOST = Rails.env.production? ?
    NEW_HOST :
    'shikimori.local'

  def self.matches? request
    HOSTS.include? request.host
  end
end
