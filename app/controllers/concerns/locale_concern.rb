module LocaleConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
    before_action :set_user_locale_from_host
    helper_method :locale_from_host
  end

  def set_locale
    I18n.locale = params[:locale]&.to_sym ||
      current_user&.locale&.to_sym ||
      locale_from_host
  end

  def set_user_locale_from_host
    return unless user_signed_in?
    return if current_user.locale_from_host == locale_from_host.to_s

    current_user.update_column :locale_from_host, locale_from_host
  end

  def locale_from_host
    ru_host? ? Types::Locale[:ru] : Types::Locale[:en]
  end
end
