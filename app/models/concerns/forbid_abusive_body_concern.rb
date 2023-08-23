module ForbidAbusiveBodyConcern
  extend ActiveSupport::Concern

  included do
    before_validation :forbid_abusive_body,
      if: -> { will_save_change_to_body? && !@is_conversion }
  end

  def forbid_abusive_body
    return if body.blank?

    if Moderations::Banhammer.instance.abusive? body
      errors.add :body, :abusive_content
      false
    end
  end
end
