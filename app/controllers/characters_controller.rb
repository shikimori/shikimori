class CharactersController < PeopleController
  before_action :js_export, only: %i[show]

  # caches_action :index, CacheHelper.cache_settings
  # caches_action :page, :show, :tooltip,
  #   cache_path: proc {
  #     entry = Character.find(params[:id].to_i)
  #     "#{Character.name}|#{params.to_json}|#{entry.updated_at.to_i}|#{entry.maybe_topic(locale_from_host).updated_at.to_i}|#{json?}"
  #   },
  #   unless: proc { user_signed_in? },
  #   expires_in: 2.days

  UPDATE_PARAMS = [
    :russian,
    :tags,
    :imageboard_tag,
    :description_ru,
    :description_en,
    *Character::DESYNCABLE,
    desynced: []
  ]

  def index
    og page_title: i18n_i(:Character, :other)

    @collection = Characters::Query
      .fetch
      .search(params[:search])
      .paginate(@page, PER_PAGE)
  end

  def show
    @itemtype = @resource.itemtype

    verify_age_restricted!(
      @resource.animes(7) + @resource.mangas(7) + @resource.ranobe(7)
    )
  end

  def seyu
    if @resource.all_seyu.none?
      return redirect_to @resource.url, status: :moved_permanently
    end

    og noindex: true
    og page_title: t(:seyu)
  end

  def animes
    if @resource.animes.none?
      redirect_to @resource.url, status: :moved_permanently
    end
    verify_age_restricted! @resource.animes

    og noindex: true
    og page_title: i18n_i('Anime', :other)
  end

  def mangas
    if @resource.mangas.none?
      redirect_to @resource.url, status: :moved_permanently
    end
    verify_age_restricted! @resource.mangas

    og noindex: true
    og page_title: i18n_i('Manga', :other)
  end

  def ranobe
    if @resource.ranobe.none?
      redirect_to @resource.url, status: :moved_permanently
    end
    verify_age_restricted! @resource.ranobe

    og noindex: true
    og page_title: i18n_i('Ranobe', :other)
  end

  def art
    if @resource.rkn_abused?
      redirect_to @resource.url, status: :moved_permanently
    end
    og page_title: t('imageboard_art')
  end

  def images
    redirect_to art_character_url(@resource), status: :moved_permanently
  end

  def cosplay
    @limit = 2
    @collection, @add_postloader =
      CosplayGalleriesQuery.new(@resource.object).postload @page, @limit

    if @collection.none?
      return redirect_to @resource.url, status: :moved_permanently
    end

    og page_title: t('cosplay')
  end

  def clubs
    if @resource.all_clubs.none?
      return redirect_to @resource.url, status: :moved_permanently
    end

    og noindex: true
    og page_title: t('in_clubs')
  end

  def tooltip
  end

  def autocomplete
    @collection = Autocomplete::Character.call(
      scope: Character.all,
      phrase: search_phrase
    )
  end

  def autocomplete_v2 # rubocop:disable Naming/VariableNumber
    og noindex: true, nofollow: true

    autocomplete
    @collection = @collection.map(&:decorate)
  end

private

  def update_params
    params
      .require(:character)
      .permit(UPDATE_PARAMS)
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
      @back_url = @resource.url
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
