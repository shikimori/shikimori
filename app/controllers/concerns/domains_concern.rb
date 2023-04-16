module DomainsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :shikimori?, :clean_host?, :new_host?
    unless Rails.env.test?
      before_action :ensure_proper_domain
      before_action :force_301_redirect
    end
  end

  def shikimori?
    ShikimoriDomain::HOSTS.include? request.host
  end

  def clean_host?
    request.host == ShikimoriDomain::CLEAN_HOST
  end

  def new_host?
    request.host == ShikimoriDomain::NEW_HOST ||
      Rails.env.development? ||
      ENV['USER'] == 'morr'
  end

  def ensure_proper_domain # rubocop:disable AbcSize
    return unless domain_redirects_appliable?
    return unless user_signed_in?
    return if !request.get? || request.xhr?

    redirect_to request.protocol + ShikimoriDomain::PROPER_HOST +
      users_magic_link_path(
        token: Users::LoginToken.encode(current_user),
        redirect_url: request.url.sub(/.*?#{request.host}/, '')
      )
  end

  def force_301_redirect
    return unless domain_redirects_appliable?
    return if user_signed_in?
    return if request.host == ShikimoriDomain::BANNED_HOST

    redirect_to request.url.sub(request.host, ShikimoriDomain::PROPER_HOST),
      status: :moved_permanently
  end

  def domain_redirects_appliable?
    request.host != ShikimoriDomain::PROPER_HOST &&
      request.get? &&
      !request.xhr?
  end
end
