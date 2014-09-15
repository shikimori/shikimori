# TODO: страница косплея, страница картинок с имиджборд
class CharactersController < PeopleController
  #layout false, only: [:tooltip]
  #before_action :authenticate_user!, only: [:edit]

  before_action :resource_redirect, if: -> { @resource }

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
    append_title! 'Поиск персонажа'
    append_title! SearchHelper.unescape(params[:search])

    @query = CharactersQuery.new params
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
  end

  # отображение персонажа
  def show
    @itemtype = @resource.itemtype
  end

  # все сэйю персонажа
  def seyu
    raise NotFound if @resource.seyu.none?
    page_title 'Сэйю'
  end

  # все аниме персонажа
  def animes
    raise NotFound if @resource.animes.none?
    page_title 'Анимеграфия'
  end

  # вся манга персонажа
  def mangas
    raise NotFound if @resource.mangas.none?
    page_title 'Мангаграфия'
  end

  def comments
    raise NotFound if @resource.thread.comments_count.zero?
    page_title 'Обсуждение персонажа'

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
    #case params[:subpage].to_sym
      #when :russian
        #append_title! 'Изменение русского имени'

      #when :description
        #append_title! 'Изменение описания'

      #else
        #raise ArgumentError.new "page: #{params[:page]}"
    #end
  #end

  # автодополнение
  def autocomplete
    @collection = CharactersQuery.new(params).complete
  end

private
  def fetch_resource
    @resource = Character.find(resource_id).decorate
  end

  def search_title
    'Поиск персонажей'
  end

  def search_url *args
    search_characters_url(*args)
  end
end
