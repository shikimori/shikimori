module CacheHelper
  def self.cache_settings
    {
      cache_path: proc { Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{json?}" },
      unless: proc { user_signed_in? },
      expires_in: 2.days
    }
  end

  def russian_names_key
    if user_signed_in? && current_user.profile_settings.russian_names?
      'rus'
    else
      'eng'
    end
  end

  def russian_genres_key
    if !user_signed_in? || !current_user.profile_settings.russian_genres?
      'eng'
    else
      'rus'
    end
  end

  def social_key
    !user_signed_in? || current_user.social ? 'social' : 'no_social'
  end
end
