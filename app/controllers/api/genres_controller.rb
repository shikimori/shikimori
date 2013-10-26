class Api::GenresController < ApplicationController
  respond_to :json
  caches_action :index,
                :expires_in => 1.month,
                :cache_path => proc { "api|genres|index|#{params[:page] || 1}" }

  def index
    @resources = Genre.all
  end
end
