class GraphqlController < ShikimoriController
  skip_before_action :touch_last_online
  skip_before_action :verify_authenticity_token
  # skip_before_action :verify_authenticity_token,
  #   if: -> { doorkeeper_token.present? }

  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user
    }
    result = ShikimoriSchema.execute query,
      variables: variables,
      context: context,
      operation_name: operation_name

    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables variables_param # rubocop:disable Metrics/MethodLength
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      # GraphQL-Ruby will validate name and type of incoming variables.
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development error
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: {
      errors: [{ message: error.message, backtrace: error.backtrace }],
      data: {}
    }, status: :internal_server_error
  end
end
