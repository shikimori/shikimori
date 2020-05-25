module FixParamsConcern
  extend ActiveSupport::Concern

  included do
    before_action :recursive_fix_params, unless: -> { request.get? }
  end

  def recursive_fix_params object = params
    object.transform_values! do |value|
      if value.is_a?(String)
        value.strip
      elsif value.is_a?(Array) && value.size == 1 && (value[0] == '')
        []
      elsif value.is_a?(ActionController::Parameters)
        recursive_fix_params value
      else
        value
      end
    end
  end
end
