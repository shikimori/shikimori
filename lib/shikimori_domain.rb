module ShikimoriDomain
  HOSTS = %w[shikimori.me shikimori.one shikimori.org] + (
    Rails.env.development? ? %w[shikimori.local shiki.local localhost] : []
  )
  BANNED_HOSTS = %w[shikimori.org shikimori.me]
  OLD_HOST = 'shikimori.me'
  NEW_HOST = 'shikimori.one'

  PROPER_HOST = Rails.env.production? ?
    NEW_HOST :
    'shikimori.local'

  def self.matches? request
    HOSTS.include? request.host
  end
end
