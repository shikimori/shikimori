class Api::UserRatesController < ShikimoriController
  respond_to :json
  caches_action :index,
                :expires_in => 1.month,
                :cache_path => proc { "api|user_rates|index|#{params[:page] || 1}" }

  def index
    @resources = postload_paginate(params[:page], 1000) do
      UserRate
    end
  end
end
