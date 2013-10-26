class Api::StudiosController < ApplicationController
  respond_to :json
  caches_action :index,
                :expires_in => 1.month,
                :cache_path => proc { "api|studios|index|#{params[:page] || 1}" }

  def index
    @resources = Studio.all
  end
end
