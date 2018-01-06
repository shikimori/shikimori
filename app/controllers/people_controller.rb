class PeopleController < DbEntriesController
  respond_to :html, only: [:show, :tooltip]
  respond_to :html, :json, only: :index
  respond_to :json, only: :autocomplete

  before_action :resource_redirect, if: :resource_id
  before_action :set_breadcrumbs, if: -> { @resource }
  before_action :js_export, only: %i[show]

  helper_method :search_url
  #caches_action :index, :page, :show, :tooltip, CacheHelper.cache_settings

  PER_PAGE = 48

  def index
    noindex
    page_title search_title

    @collection = postload_paginate(params[:page], 48) do
      Search::Person.call search_params.merge(ids_limit: 480)
    end
  end

  def show
    @itemtype = @resource.itemtype
  end

  def works
    noindex
    page_title i18n_t('participation_in_projects')
  end

  def roles
    noindex
    page_title i18n_t('roles_in_anime')
  end

  def favoured
    noindex
    redirect_to @resource.url, status: 301 if @resource.all_favoured.none?
    page_title t 'in_favorites'
  end

  def tooltip
  end

  def autocomplete
    @collection = Autocomplete::Person.call search_params
  end

private

  def update_params
    params
      .require(:person)
      .permit(:russian, *Person::DESYNCABLE)
  rescue ActionController::ParameterMissing
    {}
  end

  def search_params
    {
      scope: Person.all,
      phrase: SearchHelper.unescape(params[:search] || params[:q]),
      is_seyu: params[:kind] == 'seyu',
      is_mangaka: params[:kind] == 'mangaka',
      is_producer: params[:kind] == 'producer'
    }
  end

  def search_title
    if params[:kind] == 'producer'
      i18n_t 'search_producers'
    elsif params[:kind] == 'mangaka'
      i18n_t 'search_mangakas'
    else
      i18n_t 'search_people'
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

  def set_breadcrumbs
    if params[:action] == 'edit_field' && params[:field].present?
      @back_url = @resource.edit_url
      breadcrumb i18n_t('edit'), @resource.edit_url
    end
  end

  def js_export
    gon.push(
      person_role: {
        producer: @resource.main_role?(:producer),
        mangaka: @resource.main_role?(:mangaka),
        seyu: @resource.main_role?(:seyu),
        person: !(@resource.main_role?(:seyu) || @resource.main_role?(:producer) || @resource.main_role?(:mangaka))
      },
      is_favoured: {
        producer: @resource.producer_favoured?,
        mangaka: @resource.mangaka_favoured?,
        seyu: @resource.seyu_favoured?,
        person: @resource.person_favoured?
      }
    )
  end
end
