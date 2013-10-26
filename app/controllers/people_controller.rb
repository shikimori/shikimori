class PeopleController < ApplicationController
  layout false, only: [:tooltip]

  respond_to :html, :only => [:show, :tooltip]
  respond_to :html, :json, :only => :index
  respond_to :json, :only => :autocomplete

  caches_action :index, :page, :show, :tooltip,
                CacheHelper.cache_settings

  # отображение списка людей
  def index
    @query = PeopleQuery.new params
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
    direct
  end

  # отображение человка
  def show
    @entry = present Person.find(params[:id].to_i)
    direct

    unless @director.redirected?
      redirect_to seyu_url(@entry) if @entry.entry.seyu && !@entry.entry.producer && !@entry.entry.mangaka
    end
  end

  # тултип
  def tooltip
    @entry = Person.find params[:id].to_i
    direct
  end

  # автодополнение
  def autocomplete
    @items = PeopleQuery.new(params).complete
  end
end
