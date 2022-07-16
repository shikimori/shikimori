module PaginationConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_page
    before_action :verify_page
    helper_method :page
  end

  def page
    @page
  end

  def current_page
    @page
  end

  def set_page
    @page = [
      params[:page].present? && params[:page].respond_to?(:to_i) ?
        params[:page].to_i :
        1,
      defined?(self.class::MAX_PAGE) ? self.class::MAX_PAGE : 5000
    ].min
  end

  def verify_page
    return unless request.get? # && !json?

    if params[:page] == '1' || (params[:page].present? && @page <= 0)
      redirect_to current_url page: nil
    end
  end
end
