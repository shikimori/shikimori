class PeopleController < ShikimoriController
  #layout false, only: [:tooltip, :autocomplete]

  respond_to :html, only: [:show, :tooltip]
  respond_to :html, :json, only: :index
  respond_to :json, only: :autocomplete

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: -> { @resource }
  before_action :set_title, if: -> { @resource }

  #caches_action :index, :page, :show, :tooltip, CacheHelper.cache_settings

  # отображение списка людей
  def index
    append_title! 'Поиск людей'
    append_title! SearchHelper.unescape(params[:search])

    @query = PeopleQuery.new params
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
  end

  # отображение человка
  def show
    @itemtype = @resource.itemtype
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
