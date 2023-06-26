module ShikimoriDomain
  HOSTS = %w[shikimori.me shikimori.one shikimori.org] + (
    Rails.env.development? ? %w[shikimori.local shiki.local localhost] : []
  )
  BANNED_HOST = 'shikimori.org'
  OLD_HOST = 'shikimori.one'
  NEW_HOST = 'shikimori.me'

  PROPER_HOST = Rails.env.production? ?
    NEW_HOST :
    'shikimori.local'

  def self.matches? request
    HOSTS.include? request.host
  end
end
