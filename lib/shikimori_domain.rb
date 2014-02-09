class ShikimoriDomain
  HOSTS = ['dev.shikimori.org', 'shikimori.dev', 'shikimori.org']

  def self.matches? request
    !AnimeOnlineDomain.matches? request
  end
end
