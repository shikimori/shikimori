module CacheHelper
  I18N_HASH = {
    ru: Digest::MD5.hexdigest(I18n.backend.translate(:ru, '.').to_json),
    en: Digest::MD5.hexdigest(I18n.backend.translate(:en, '.').to_json)
  }

  def cache(name = {}, *args)
    super Array(name) + [I18n.locale, I18N_HASH[I18n.locale]], *args
  end

  def self.cache_settings
    {
      cache_path: proc { "#{params[:controller]}_#{params[:action]}_#{I18n.locale}" +
        Digest::MD5.hexdigest("#{request.path}|#{params.to_json}|#{cookies[ShikimoriController::COOKIE_AGE_OVER_18].to_json}") +
        "_#{json?}_#{request.xhr?}_#{turbolinks_request?}_#{request.host}" },
      unless: proc { user_signed_in? },
      expires_in: 2.days
    }
  end

  def social_key
    !user_signed_in? || current_user.preferences.show_social_buttons? ?
      'social' :
      'no_social'
  end
end
