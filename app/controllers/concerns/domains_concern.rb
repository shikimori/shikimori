module DomainsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :shikimori?, :anime_online?
    helper_method :ru_host?
  end

  def shikimori?
    ShikimoriDomain::HOSTS.include?(request.host)
  end

  def anime_online?
    AnimeOnlineDomain::HOSTS.include?(request.host)
  end

  def ru_host?
    return true if Rails.env.test?
    return true if anime_online?

    ShikimoriDomain::RU_HOSTS.include?(request.host)
  end
end
