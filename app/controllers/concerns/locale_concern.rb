module LocaleConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
    before_action :ensure_only_russian_locale_indexed
  end

  def set_locale
    I18n.locale = user_signed_in? ?
      (params[:locale].presence || current_user.locale).to_sym :
      :ru
  end

  def ensure_only_russian_locale_indexed
    return if I18n.russian? || params[:locale].blank?

    og(
      noindex: true,
      nofollow: true,
      canonical_url: current_url(locale: nil)
    )
  end
end
