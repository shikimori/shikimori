module OptionableContentConcern
  extend ActiveSupport::Concern

  included do
    helper_method :with_optionable_content_keys, :genres_v2?, :optionable_content_keys
  end

  def optionable_content_keys
    [genres_v2?]
  end

  def genres_v2?
    !!current_user&.admin?
  end

  def with_optionable_content_keys *keys
    keys + optionable_content_keys
  end
end
