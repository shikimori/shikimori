module OptionableContentConcern
  extend ActiveSupport::Concern

  included do
    helper_method :genres_v2?
  end

  def optionable_content_keys
    [genres_v2?]
  end

  def genres_v2?
    !!current_user&.admin?
  end
end
