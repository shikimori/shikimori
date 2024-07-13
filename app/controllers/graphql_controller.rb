class GraphqlController < ShikimoriController
  skip_before_action :touch_last_online
  skip_before_action :verify_authenticity_token
  # skip_before_action :verify_authenticity_token,
  #   if: -> { doorkeeper_token.present? }

  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute # rubocop:disable Metrics/MethodLength
    variables = prepare_variables(params[:variables])
    query = params[:query] || ''
    operation_name = params[:operationName]
    context = {
      current_user:
    }

    result =
      if query.include? 'IntrospectionQuery'
        ShikimoriSchema.execute GraphQL::Introspection::INTROSPECTION_QUERY,
          max_depth: 13,
          max_complexity: 181
      else
        ShikimoriSchema.execute(query,
          variables:,
          context:,
          operation_name:)
      end

    render json: result
  rescue StandardError => e
    if Rails.env.development?
      handle_error_in_development e
    else
      handle_error_in_production e
    end
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

  def handle_error_in_production error
    notify_erorr error

    render json: {
      errors: [{
        exception: error.class.name,
        message: error.message
        # backtrace: error.backtrace.first.sub(Rails.root.to_s, '')
      }]
    }, status: :internal_server_error
  end

  # do not touch it on api access
  def touch_last_online
  end
end
