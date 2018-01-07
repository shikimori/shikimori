class CharactersController < PeopleController
  before_action :js_export, only: %i[show]

  #caches_action :index, CacheHelper.cache_settings
  #caches_action :page, :show, :tooltip,
    #cache_path: proc {
      #entry = Character.find(params[:id].to_i)
      #"#{Character.name}|#{params.to_json}|#{entry.updated_at.to_i}|#{entry.maybe_topic(locale_from_host).updated_at.to_i}|#{json?}"
    #},
    #unless: proc { user_signed_in? },
    #expires_in: 2.days

  def index
    page_title i18n_i(:Character, :other)

    @page = [params[:page].to_i, 1].max

    @collection = Characters::Query
      .fetch
      .search(params[:search])
      .paginate(@page, PER_PAGE)
  end

  def show
    @itemtype = @resource.itemtype
  end

  def seyu
    noindex
    redirect_to @resource.url, status: 301 if @resource.seyu.none?
    page_title t(:seyu)
  end

  def animes
    noindex
    redirect_to @resource.url, status: 301 if @resource.animes.none?
    page_title i18n_i('Anime', :other)
  end

  def mangas
    noindex
    redirect_to @resource.url, status: 301 if @resource.mangas.none?
    page_title i18n_i('Manga', :other)
  end

  def ranobe
    noindex
    redirect_to @resource.url, status: 301 if @resource.ranobe.none?
    page_title i18n_i('Ranobe', :other)
  end

  def art
    page_title t('imageboard_art')
  end

  def images
    noindex
    redirect_to art_character_url(@resource), status: 301
  end

  def cosplay
    @page = [params[:page].to_i, 1].max
    @limit = 2
    @collection, @add_postloader = CosplayGalleriesQuery.new(@resource.object).postload @page, @limit

    redirect_to @resource.url, status: 301 if @collection.none?

    page_title t('cosplay')
  end

  def favoured
    noindex
    redirect_to @resource.url, status: 301 if @resource.all_favoured.none?
    page_title t('in_favorites')
  end

  def clubs
    noindex
    redirect_to @resource.url, status: 301 if @resource.all_linked_clubs.none?
    page_title i18n_i('Club', :other)
  end

  def tooltip
  end

  def edit
    noindex
    page_title i18n_t('entry_edit')

    @page = params[:page]
  end

  def autocomplete
    @collection = Autocomplete::Character.call(
      scope: Character.all,
      phrase: params[:search] || params[:q]
    )
  end

private

  def update_params
    params
      .require(:character)
      .permit(
        :russian,
        :tags,
        :description_ru,
        :description_en,
        *Character::DESYNCABLE
      )
  rescue ActionController::ParameterMissing
    {}
  end

  def search_url *args
    characters_url(*args)
  end

  def set_breadcrumbs
    breadcrumb i18n_t('all_characters'), characters_url

    if params[:action] != 'show'
      breadcrumb(
        UsersHelper.localized_name(@resource, current_user),
        @resource.url
      )
      @back_url = @resource.edit_url
    end

    if params[:action] == 'edit_field' && params[:field].present?
      @back_url = @resource.edit_url
      breadcrumb i18n_t('edit'), @resource.edit_url
    end
  end

  def js_export
    gon.push is_favoured: @resource.favoured?
  end
end
