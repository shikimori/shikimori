module CanCanGet404Concern
  extend ActiveSupport::Concern

  included do
    prepend FetchResouceOverride
  end

  def forbidden_error error
    not_found_error error if request.get?
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
