module ShikimoriDomain
  HOSTS = ['dev.shikimori.org', 'shikimori.dev', 'shikimori.org']
  HOST = "shikimori.#{Rails.env.development? ? :dev : :org}"

  def self.matches? request
    !AnimeOnlineDomain.matches? request
  end
end
