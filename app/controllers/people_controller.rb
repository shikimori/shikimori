class PeopleController < ShikimoriController
  respond_to :html, only: [:show, :tooltip]
  respond_to :html, :json, only: :index
  respond_to :json, only: :autocomplete

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: :resource_id
  before_action :role_redirect, if: -> { resource_id && params[:action] != 'tooltip' }

  helper_method :search_url
  #caches_action :index, :page, :show, :tooltip, CacheHelper.cache_settings

  def index
    noindex
    page_title search_title

    @collection = postload_paginate(params[:page], 48) { search_query.fetch }
  end

  def show
    @itemtype = @resource.itemtype
  end

  def works
    noindex
    page_title 'Участие в проектах'
  end

  # TODO: удалить после 05.2015
  def comments
    noindex
    redirect_to UrlGenerator.instance.topic_url(@resource.thread), status: 301
  end

  def favoured
    noindex
    redirect_to @resource.url, status: 301 if @resource.all_favoured.none?
    page_title 'В избранном'
  end

  def tooltip
    @resource = SeyuDecorator.new @resource.object if @resource.main_role?(:seyu)
  end

  def autocomplete
    @collection = PeopleQuery.new(params).complete
  end

private

  def search_title
    if params[:kind] == 'producer'
      'Поиск режиссёров'
    elsif params[:kind] == 'mangaka'
      'Поиск мангак'
    else
      'Поиск людей'
    end
  end

  def search_url *args
    if params[:kind] == 'producer'
      search_producers_url(*args)
    elsif params[:kind] == 'mangaka'
      search_mangakas_url(*args)
    else
      search_people_url(*args)
    end
  end

  def search_query
    PeopleQuery.new params
  end

  def role_redirect
    redirect_to seyu_url(@resource), status: 301 if @resource.main_role?(:seyu)
  end
end
