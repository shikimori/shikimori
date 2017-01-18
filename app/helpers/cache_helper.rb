module CacheHelper
  I18N_HASH = {
    ru: Digest::MD5.hexdigest(I18n.backend.translate(:ru, '.').to_json),
    en: Digest::MD5.hexdigest(I18n.backend.translate(:en, '.').to_json)
  }

  class << self
    def keys *args
      args + [
        I18n.locale,
        I18N_HASH[I18n.locale],
        CacheHelperInstance.instance.subdomain,
        CacheHelperInstance.instance.ru_domain?
      ]
    end

    def cache_settings
      {
        cache_path: lambda {
          "#{params[:controller]}_#{params[:action]}_#{I18n.locale}" +
          Digest::MD5.hexdigest("#{request.path}|#{params.to_json}|"\
            "#{cookies[ShikimoriController::COOKIE_AGE_OVER_18].to_json}") +
          "_#{json?}_#{request.xhr?}_#{turbolinks_request?}_#{request.host}"
        },
        unless: proc { user_signed_in? },
        expires_in: 2.days
      }
    end
  end

  def cache(name = {}, *args)
    super CacheHelper.keys(*Array(name)), *args
  end

  def social_key
    !user_signed_in? || current_user.preferences.show_social_buttons? ?
      'social' :
      'no_social'
  end
end

class CacheHelperInstance
  include Singleton
  include Draper::ViewHelpers

  def subdomain
    h.request.subdomain
  end

  def ru_domain?
    h.ru_domain?
  end
end
