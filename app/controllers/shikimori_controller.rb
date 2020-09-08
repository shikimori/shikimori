# TODO: merge into ApplicationController
# TODO: extract related methods into concerns
class ShikimoriController < ApplicationController
  before_action { og noindex: true, nofollow: true unless shikimori? }
  COOKIE_AGE_OVER_18 = :confirmed_age_over_18

  helper_method :censored_forbidden?
  helper_method :domain_migration_note

  rescue_from ForceRedirect do |exception|
    redirect_to exception.url, status: :moved_permanently
  end

  def fetch_resource # rubocop:disable AbcSize
    @resource ||= resource_klass.find(
      CopyrightedIds
        .instance
        .restore(resource_id, resource_klass.base_class.name.downcase)
    )
    @resource = @resource.decorate
    instance_variable_set "@#{resource_klass.name.downcase}", @resource

    if request.get?
      if @resource.respond_to? :name
        og page_title: @resource.name
      elsif @resource.respond_to? :title
        og page_title: @resource.title
      end

      raise AgeRestricted if @resource.try(:censored?) && censored_forbidden?
    end
  end

  def ensure_redirect! expected_url
    return if %w[rss os json].include?(request.format)

    if URI(request.url).path != URI(expected_url).path
      raise(
        ForceRedirect,
        params[:locale] ?
          Url.new(expected_url).params(locale: params[:locale]).to_s :
          expected_url
      )
    end
  rescue URI::InvalidURIError
    raise ForceRedirect, expected_url
  end

  def resource_redirect
    return if resource_id.nil?
    return if resource_id == @resource.to_param
    return if request.method != 'GET'
    return if params[:action] == 'new'

    redirect_to current_url(resource_id_key => @resource.to_param), status: :moved_permanently

    false
  end

  def resource_id
    @resource_id ||= params[resource_id_key]
  end

  def resource_id_key
    key = "#{resource_klass.name.downcase}_id".to_sym
    params[key] ? key : :id
  end

  def resource_klass
    self.class
      .name
      .sub(/Controller$/, '')
      .sub(/.*:/, '')
      .singularize
      .constantize
  end

  # TODO: delete
  def check_post_permission
    return unless user_signed_in?

    unless current_user.can_post?
      banned_till = current_user.read_only_at.strftime('%H:%M %d.%m.%Y')

      raise CanCan::AccessDenied, t(
        'shikimori_controller.you_are_banned',
        datetime: banned_till,
        gender: current_user.sex
      )
    end
  end

  def domain_migration_note
    user_signed_in? && request.host != Shikimori::DOMAINS[:production] && Rails.env.production?
  end
end
