module LocaleConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  def set_locale
    I18n.locale = params[:locale]&.to_sym || current_user&.locale&.to_sym
  end
end
