module PaginationConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_page, :verify_page
    helper_method :page
  end

  def page
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
    if params[:page] == '1' || (params[:page].present? && @page <= 0)
      redirect_to current_url page: nil if params[:page] == '1' || params[:page].present?
    end
  end
end
