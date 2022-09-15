module CanCanGet404Concern
  extend ActiveSupport::Concern

  included do
    prepend FetchResouceOverride
  end

  # this method is checked in error handler of errors concern
  def cancan_get_404? error
    request.get? && error.is_a?(CanCan::AccessDenied)
  end

  module FetchResouceOverride
    def fetch_resource
      super
    rescue AgeRestricted
      authorize! :read, @resource
      raise
    end
  end
end
