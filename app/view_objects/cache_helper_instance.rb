class CacheHelperInstance
  include Singleton
  include Draper::ViewHelpers

  delegate :ru_host?, to: :h

  def self.cache_keys *args
    instance.cache_keys(*args)
  end

  # I18N_HASH = {
  #   ru: Digest::MD5.hexdigest(
  #     I18n.backend.translate(:ru, '.')
  #       .except(:activerecord, :apipie)
  #       .reject { |key, _| key =~ /_controller|_decorator/ }
  #       .keys
  #       .to_json
  #   ),
  #   en: Digest::MD5.hexdigest(
  #     I18n.backend.translate(:en, '.')
  #       .except(:activerecord, :apipie)
  #       .reject { |key, _| key =~ /_controller|_decorator/ }
  #       .keys
  #       .to_json
  #   )
  # }

  def request_domain
    h.request.domain
  end

  # def request_subdomain
  #   h.request.subdomain
  # end

  def cache_keys *args
    args
      .map do |v|
        if v.respond_to? :cache_key_with_version
          v.cache_key_with_version
        elsif v.respond_to? :cache_key
          v.cache_key
        else
          v
        end
      end
      .compact + [
        I18n.locale,
        # I18N_HASH[I18n.locale],
        request_domain
        # request_subdomain
      ]
  end

  # def cache_settings
  #   {
  #     cache_path: -> {
  #       "#{params[:controller]}_#{params[:action]}_#{I18n.locale}" +
  #       Digest::MD5.hexdigest("#{request.path}|#{params.to_json}|"\
  #         "#{cookies[ShikimoriController::COOKIE_AGE_OVER_18].to_json}") +
  #       "_#{json?}_#{request.xhr?}_#{turbolinks_request?}_#{request.host}"
  #     },
  #     unless: -> { user_signed_in? },
  #     expires_in: 2.days
  #   }
  # end
end
