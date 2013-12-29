class CharactersController < PeopleController
  layout false, only: [:tooltip]
  before_filter :authenticate_user!, only: [:edit]

  caches_action :index,
                CacheHelper.cache_settings

  caches_action :page, :show, :tooltip,
                cache_path: proc {
                  entry = Character.find(params[:id].to_i)
                  "#{Character.name}|#{params.to_json}|#{entry.updated_at.to_i}|#{entry.thread.updated_at.to_i}|#{json?}"
                },
                unless: proc { user_signed_in? },
                expires_in: 2.days


  # список персонажей
  def index
    @query = CharactersQuery.new params
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
    direct
  end

  # отображение персонажа
  def show
    @entry = CharacterDecorator.find params[:id].to_i
    direct
  end

  # подстраница персонажа
  def page
    show
    render :show unless @director.redirected?
  end

  # тултип
  def tooltip
    @entry = Character.find params[:id].to_i
    direct
  end

  # редактирование персонажа
  def edit
    show
    render :show unless @director.redirected?
  end

  # автодополнение
  def autocomplete
    @items = CharactersQuery.new(params).complete
  end

private
  def klass
    Character
  end
end
