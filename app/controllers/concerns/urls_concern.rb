module UrlsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_url
    helper_method :url_params
    helper_method :safe_params
  end

  def current_url merged = nil
    url_for url_params(merged)
  end

  # converts params to an object, which can be passed to url helpers
  def url_params merged = nil
    new_params = safe_params
      .to_unsafe_h
      .symbolize_keys

    merged ? new_params.merge(merged) : new_params
  end

  # Use this in place of params when generating links to Excel etc.
  # See https://github.com/rails/rails/issues/26289
  def safe_params
    params.except(:host, :port, :protocol, :authenticity_token).permit!
  end
end
