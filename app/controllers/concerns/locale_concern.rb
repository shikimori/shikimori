module LocaleConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
    before_action :ensure_only_russian_locale_indexed
  end

  def set_locale
    I18n.locale = params[:locale]&.to_sym || current_user&.locale&.to_sym
  end

  def ensure_only_russian_locale_indexed
    return if I18n.russian?

    og(
      noindex: true,
      nofollow: true,
      canonical_url: current_url(locale: nil)
    )
  end
end
