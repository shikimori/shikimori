class Api::AnimesController < ApplicationController
  respond_to :json, :xml
  caches_action :index,
                :expires_in => 1.month,
                :cache_path => proc { "api|animes|index|#{params[:page] || 1}" }

  def index
    @resources = postload_paginate(params[:page], 500) do
      Anime.includes(:genres).includes(:studios)
    end
  end

  def show
    @resource = Anime.find params[:id]
  end
end
