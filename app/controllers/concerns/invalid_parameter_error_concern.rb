module InvalidParameterErrorConcern
  extend ActiveSupport::Concern

  included do
    rescue_from InvalidParameterError, with: :invalid_parameter_error
  end

  def invalid_parameter_error error
    redirect_to current_url(error.field => nil) unless is_a? Api::V1Controller
  end
end
