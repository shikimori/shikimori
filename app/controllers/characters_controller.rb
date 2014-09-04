class CharactersController < PeopleController
  layout false, only: [:tooltip]
  before_filter :authenticate_user!, only: [:edit]

  before_action :fetch_resource
  before_action :check_redirect, if: -> { @resource }

  #caches_action :index, CacheHelper.cache_settings
  #caches_action :page, :show, :tooltip,
    #cache_path: proc {
      #entry = Character.find(params[:id].to_i)
      #"#{Character.name}|#{params.to_json}|#{entry.updated_at.to_i}|#{entry.thread.updated_at.to_i}|#{json?}"
    #},
    #unless: proc { user_signed_in? },
    #expires_in: 2.days


  # список персонажей
  def index
    @query = CharactersQuery.new params
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
    direct
  end

  # отображение персонажа
  def show
    @itemtype = @resource.itemtype
  end

  # все сэйю персонажа
  def seyu
    page_title 'Сэйю'
    raise NotFound if @resource.seyu.none?
  end

  # все аниме персонажа
  def animes
    page_title 'Анимеграфия'
    raise NotFound if @resource.animes.none?
  end

  # вся манга персонажа
  def mangas
    page_title 'Мангаграфия'
    raise NotFound if @resource.mangas.none?
  end

  def comments
    noindex
    page_title "Обсуждение персонажа"

    @thread = TopicDecorator.new @resource.thread
    @thread.topic_mode!
  end

  # подстраница персонажа
  #def page
    #show
    #render :show unless @director.redirected?
  #end

  # тултип
  def tooltip
    @entry = Character.find params[:id].to_i
  end

  # редактирование персонажа
  #def edit
    #show
    #render :show unless @director.redirected?
  #end

  # автодополнение
  def autocomplete
    @items = CharactersQuery.new(params).complete
  end

private
  def klass
    Character
  end

  def fetch_resource
    @resource = klass.find(resource_id.to_i).decorate if resource_id
  end
end
