class Api::ReviewsController < ApplicationController
  respond_to :json
  caches_action :show,
                :expires_in => 1.hour,
                :cache_path => proc { "api|reviews|show|#{params[:id] || 1}" }

  def show
    @resource = Review.find params[:id]
  end
end
