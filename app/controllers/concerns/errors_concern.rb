module ErrorsConcern
  extend ActiveSupport::Concern

  NOT_FOUND_ERRORS = [
    ActionController::RoutingError,
    ActiveRecord::RecordNotFound,
    AbstractController::ActionNotFound,
    ActionController::UnknownFormat
  ]

  included do
    unless Rails.env.test?
      rescue_from Exception, with: :runtime_error
    else
      rescue_from StatusCodeError, with: :runtime_error
    end
  end

  # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
  def runtime_error e
    Honeybadger.notify(e) if defined? Honeybadger
    Raven.capture_exception(e) if defined? Raven
    Appsignal.set_error(e) if defined? Appsignal

    # NamedLogger
      # .send("#{Rails.env}_errors")
      # .error("#{e.message}\n#{e.backtrace.join("\n")}")
    # Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")

    raise e if local_addr? && (
      !e.is_a?(AgeRestricted) &&
      !e.is_a?(CopyrightedResource) &&
      !e.is_a?(Forbidden)
    )

    if NOT_FOUND_ERRORS.include? e.class
      not_found_error(e)

    elsif e.is_a?(AgeRestricted)
      age_restricted_error(e)

    elsif e.is_a?(Forbidden) || e.is_a?(CanCan::AccessDenied)
      forbidden_error(e)

    elsif e.is_a?(StatusCodeError)
      status_code_error(e)

    elsif e.is_a?(CopyrightedResource)
      copyrighted_error(e)

    elsif is_a?(Api::V1Controller) || json?
      api_error(e)

    else
      standard_error(e)
    end
  end
  # rubocop:enable MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity

private

  def not_found_error _e
    if error_json_response?
      render json: { message: t('page_not_found'), code: 404 }, status: 404
    else
      render 'pages/page404', layout: false, status: 404, formats: :html
    end
  end

  def age_restricted_error _e
    render 'pages/age_restricted', layout: false, formats: :html
  end

  def forbidden_error e
    if error_json_response?
      render json: { message: e.message, code: 403 }, status: 403
    else
      render plain: e.message, status: 403
    end
  end

  def status_code_error e
    render json: {}, status: e.status
  end

  def copyrighted_error e
    resource = e.resource
    @new_url = url_for safe_params.merge(resource_id_key => resource.to_param)

    if params[:format] == 'rss'
      redirect_to @new_url, status: 301
    else
      render 'pages/page_moved.html', layout: false, status: 404, formats: :html
    end
  end

  def api_error e
    render(
      json: {
        code: 503,
        exception: e.class.name,
        message: e.message,
        backtrace: e.backtrace.first.sub(Rails.root.to_s, '')
      },
      status: 503
    )
  end

  def standard_error _e
    @page_title = t 'error'
    render 'pages/page503.html', layout: false, status: 503, formats: :html
  end

  def error_json_response?
    json? || (is_a?(Api::V1Controller) && !params[:frontend])
  end
end
