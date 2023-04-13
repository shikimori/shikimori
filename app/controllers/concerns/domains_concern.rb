module DomainsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :shikimori?, :ru_host?, :clean_host?
    before_action :ensure_proper_domain, if: :user_signed_in?
    before_action :force_301_redirect, unless: :user_signed_in?
  end

  def shikimori?
    ShikimoriDomain::HOSTS.include? request.host
  end

  def ru_host?
    return true if Rails.env.test? || ENV['USER'] == 'morr'
    return true if Rails.const_defined? :Console

    ShikimoriDomain::RU_HOSTS.include? request.host
  end

  def clean_host?
    Rails.env.development? ||
      ENV['USER'] == 'morr' ||
      request.host == ShikimoriDomain::CLEAN_HOST
  end

  def ensure_proper_domain
    return if request.host == ShikimoriDomain::PROPER_HOST
    return if !request.get? || request.xhr?

    redirect_to request.protocol + ShikimoriDomain::PROPER_HOST +
      users_magic_link_path(
        token: Users::LoginToken.encode(current_user),
        redirect_url: request.url.sub(/.*?#{request.host}/, '')
      )
  end

  def force_301_redirect
    return if !request.get? || request.xhr?
    return if request.host == ShikimoriDomain::BANNED_HOST

    redirect_to request.url.sub(request.host, ShikimoriDomain::PROPER_HOST),
      status: :moved_permanently
  end
end
