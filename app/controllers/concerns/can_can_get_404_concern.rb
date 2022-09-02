module CanCanGet404Concern
  extend ActiveSupport::Concern

  # this method is checked in error handler of errors concern
  def cancan_get_404? error
    request.get? && error.is_a?(CanCan::AccessDenied)
  end
end
