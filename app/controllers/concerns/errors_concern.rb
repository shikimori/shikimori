module ErrorsConcern
  extend ActiveSupport::Concern

  NOT_FOUND_ERRORS = [
    ActionController::RoutingError,
    ActiveRecord::RecordNotFound,
    AbstractController::ActionNotFound,
    ActionController::UnknownFormat
  ]

  included do
    if Rails.env.test?
      rescue_from StatusCodeError, with: :runtime_error
    else
      rescue_from Exception, with: :runtime_error
    end
  end

  def runtime_error error # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    if defined? Airbrake
      Airbrake.notify error,
        url: request.url,
        session: JSON.parse(session.to_json),
        cookies: JSON.parse(cookies.to_json)
    end
    Honeybadger.notify error if defined? Honeybadger
    Appsignal.set_error error if defined? Appsignal
    Bugsnag.notify error if defined? Bugsnag
    capture_sentry error if defined? Raven

    NamedLogger
      .send("#{Rails.env}_errors")
      .error("#{error.message}\n#{error.backtrace.join("\n")}")
    Rails.logger.error("#{error.message}\n#{error.backtrace.join("\n")}")

    raise error if (request.ip == '127.0.0.1' || request.ip == '::1') && (
      !error.is_a?(AgeRestricted) &&
        !error.is_a?(RknBanned) &&
        !error.is_a?(CopyrightedResource) &&
        !error.is_a?(CanCan::AccessDenied)
    )

    if NOT_FOUND_ERRORS.include? error.class
      not_found_error error

    elsif error.is_a? RknBanned
      rkn_banned_error error

    elsif error.is_a? AgeRestricted
      age_restricted_error error

    elsif error.is_a? CanCan::AccessDenied
      forbidden_error error

    elsif error.is_a? StatusCodeError
      status_code_error error

    elsif error.is_a? CopyrightedResource
      copyrighted_error error

    elsif is_a?(Api::V1Controller) || json?
      api_error error

    else
      standard_error error
    end
  end

private

  def not_found_error _error
    if error_json_response?
      render json: { message: t('page_not_found'), code: 404 }, status: :not_found
    else
      render 'pages/page404', layout: false, status: :not_found, formats: :html
    end
  end

  def rkn_banned_error _error
    if error_json_response?
      render plain: 'rkn_banned', status: :unavailable_for_legal_reasons
    else
      render 'pages/rkn_banned', layout: false, formats: :html
    end
  end

  def age_restricted_error _error
    if error_json_response?
      render plain: 'age_restricted', status: :unavailable_for_legal_reasons
    else
      render 'pages/age_restricted', layout: false, formats: :html
    end
  end

  def forbidden_error error
    if error_json_response?
      render json: { message: error.message, code: 403 }, status: :forbidden
    else
      render plain: error.message, status: :forbidden
    end
  end

  def status_code_error error
    render json: {}, status: error.status
  end

  def copyrighted_error error
    resource = error.resource
    @new_url = url_for(
      safe_params.merge(copyrighted_resource_id_key => resource.to_param, ignore302: nil)
    )

    if user_signed_in? ||
        %w[rss os json].include?(request.format) ||
        params[:ignore302] == '1'
      redirect_to @new_url, status: :moved_permanently
    else
      render 'pages/page_moved.html', layout: false, status: :not_found, formats: :html
    end
  end

  def copyrighted_resource_id_key
    resource_id_key
  end

  def api_error error
    render(
      json: {
        code: 503,
        exception: error.class.name,
        message: error.message,
        backtrace: error.backtrace.first.sub(Rails.root.to_s, '')
      },
      status: :service_unavailable
    )
  end

  def standard_error _error
    og page_title: t('error')
    render 'pages/page503.html', layout: false, status: :service_unavailable, formats: :html
  end

  def error_json_response?
    json? || (is_a?(Api::V1Controller) && !params[:frontend])
  end

  def capture_sentry error
    if current_user.present?
      Raven.user_context id: current_user.id
      Raven.extra_context params: params.to_unsafe_h, url: request.url
    end

    Raven.capture_exception error
  end
end
