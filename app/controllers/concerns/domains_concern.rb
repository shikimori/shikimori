module DomainsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :shikimori?, :ru_host?, :clean_host?
  end

  def shikimori?
    ShikimoriDomain::HOSTS.include? request.host
  end

  def ru_host?
    return true if Rails.env.test?

    ShikimoriDomain::RU_HOSTS.include? request.host
  end

  def clean_host?
    Rails.env.development? || ShikimoriDomain::CLEAN_HOST == request.host
  end
end
