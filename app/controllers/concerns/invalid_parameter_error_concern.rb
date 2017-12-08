module InvalidParameterErrorConcern
  extend ActiveSupport::Concern

  included do
    rescue_from InvalidParameterError, with: :invalid_parameter_error
  end

  def invalid_parameter_error e
    unless is_a? Api::V1Controller
      redirect_to url_for(url_params(e.field => nil))
    end
  end
end
