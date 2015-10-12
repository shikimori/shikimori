# TODO: страница косплея, страница картинок с имиджборд
class CharactersController < PeopleController
  skip_before_action :role_redirect

  before_action { page_title i18n_i('Character', :other) }

  #caches_action :index, CacheHelper.cache_settings
  #caches_action :page, :show, :tooltip,
    #cache_path: proc {
      #entry = Character.find(params[:id].to_i)
      #"#{Character.name}|#{params.to_json}|#{entry.updated_at.to_i}|#{entry.thread.updated_at.to_i}|#{json?}"
    #},
    #unless: proc { user_signed_in? },
    #expires_in: 2.days

  def show
    @itemtype = @resource.itemtype
  end

  # все сэйю персонажа
  def seyu
    noindex
    redirect_to @resource.url, status: 301 if @resource.seyu.none?
    page_title t(:seyu)
  end

  # все аниме персонажа
  def animes
    noindex
    redirect_to @resource.url, status: 301 if @resource.animes.none?
    page_title t('animegraphy')
  end

  # вся манга персонажа
  def mangas
    noindex
    redirect_to @resource.url, status: 301 if @resource.mangas.none?
    page_title t('mangagraphy')
  end

  # TODO: удалить после 05.2015
  def comments
    redirect_to UrlGenerator.instance.topic_url(@resource.thread), status: 301
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
    page_title t('in_favourites')
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
    @collection = CharactersQuery.new(params).complete
  end

private

  def update_params
    params
      .require(:character)
      .permit(:russian, :tags, :description, :source, *Character::DESYNCABLE)
  end

  def search_title
    i18n_t('search_characters')
  end

  def search_url *args
    search_characters_url(*args)
  end

  def search_query
    CharactersQuery.new params
  end
end
