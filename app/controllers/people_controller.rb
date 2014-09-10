class PeopleController < ShikimoriController
  #layout false, only: [:tooltip, :autocomplete]

  respond_to :html, only: [:show, :tooltip]
  respond_to :html, :json, only: :index
  respond_to :json, only: :autocomplete

  before_action :fetch_resource, if: :resource_id
  before_action :set_title, if: -> { @resource }

  #caches_action :index, :page, :show, :tooltip, CacheHelper.cache_settings

  # отображение списка людей
  def index
    @query = PeopleQuery.new params
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
    direct
  end

  # отображение человка
  def show
    @entry = PersonDecorator.find params[:id].to_i
    direct

    unless @director.redirected?
      redirect_to seyu_url(@entry) if @entry.seyu && !@entry.producer && !@entry.mangaka
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

private
  def set_title
    page_title @resource.name
  end

  def fetch_resource
    @resource = Person.find(resource_id).decorate
  end
end
