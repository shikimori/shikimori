class ShikimoriDomain
  HOSTS = ['dev.shikimori.de', 'dev.shikimori.org', 'shikimori.dev', 'shikimori.org', 'shikimori.de']

  def self.matches? request
    !AnimeOnlineDomain.matches? request
  end
end
