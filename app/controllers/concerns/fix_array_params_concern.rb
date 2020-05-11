module FixArrayParamsConcern
  extend ActiveSupport::Concern

  included do
    before_action :fix_array_params, unless: -> { request.get? }
  end

  def fix_array_params object = params
    object.transform_values! do |value|
      if value.is_a?(Array) && value.size == 1 && (value[0] == '')
        []
      elsif value.is_a?(ActionController::Parameters)
        fix_array_params value
      else
        value
      end
    end
  end
end
