class PeopleController < DbEntriesController # rubocop:disable ClassLength
  before_action :resource_redirect, if: :resource_id
  before_action :set_breadcrumbs, if: -> { @resource }
  before_action :js_export, only: %i[show]

  helper_method :search_url
  # caches_action :index, :page, :show, :tooltip, CacheHelper.cache_settings

  PER_PAGE = 48
  UPDATE_PARAMS = [
    :russian,
    *Person::DESYNCABLE,
    desynced: []
  ]

  def index
    og page_title: search_title

    @collection = People::Query
      .fetch(is_mangaka: mangaka?, is_producer: producer?, is_seyu: seyu?)
      .search(
        params[:search],
        is_mangaka: mangaka?,
        is_producer: producer?,
        is_seyu: seyu?
      )
      .paginate(@page, PER_PAGE)
  end

  def show
    @itemtype = @resource.itemtype

    verify_age_restricted! @resource.best_works
  end

  def works
    og noindex: true
    og page_title: i18n_t('participation_in_projects')

    verify_age_restricted! @resource.works
  end

  def roles
    og noindex: true
    og page_title: i18n_t('roles_in_anime')

    verify_age_restricted!(
      @resource.character_works.flat_map { |v| v[:animes] }
    )
  end

  def favoured
    return redirect_to @resource.url, status: :moved_permanently if @resource.all_favoured.none?

    og noindex: true
    og page_title: t('in_favorites')
  end

  def tooltip
  end

  def autocomplete
    @phrase = params[:search] || params[:q]
    @collection = Autocomplete::Person.call(
      scope: Person.all,
      phrase: @phrase,
      is_seyu: seyu?,
      is_mangaka: mangaka?,
      is_producer: producer?
    )
  end

  def autocomplete_v2
    og noindex: true, nofollow: true

    autocomplete
    @collection = @collection
      .includes(:person_roles)
      .map(&:decorate)
  end

private

  def update_params
    params
      .require(:person)
      .permit(UPDATE_PARAMS)
  rescue ActionController::ParameterMissing
    {}
  end

  def search_title
    if producer?
      i18n_t 'search_producers'
    elsif mangaka?
      i18n_t 'search_mangakas'
    elsif seyu?
      i18n_t 'search_seyu'
    else
      i18n_t 'search_people'
    end
  end

  def search_url *args
    if producer?
      producers_people_url(*args)
    elsif mangaka?
      mangakas_people_url(*args)
    elsif seyu?
      seyu_people_url(*args)
    else
      people_url(*args)
    end
  end

  def set_breadcrumbs # rubocop:disable AbcSize
    breadcrumb i18n_t('all_people'), people_url

    breadcrumb i18n_t('producers'), producers_people_url if @resource.producer?
    breadcrumb i18n_t('mangakas'), mangakas_people_url if @resource.mangaka?
    breadcrumb i18n_t('seyu'), seyu_people_url if @resource.seyu?

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

  def js_export # rubocop:disable MethodLength
    gon.push(
      person_role: {
        producer: @resource.main_role?(:producer),
        mangaka: @resource.main_role?(:mangaka),
        seyu: @resource.main_role?(:seyu),
        person: !(
          @resource.main_role?(:seyu) ||
          @resource.main_role?(:producer) ||
          @resource.main_role?(:mangaka)
        )
      },
      is_favoured: {
        producer: @resource.producer_favoured?,
        mangaka: @resource.mangaka_favoured?,
        seyu: @resource.seyu_favoured?,
        person: @resource.person_favoured?
      }
    )
  end

  def mangaka?
    params[:kind] == 'mangaka'
  end

  def producer?
    params[:kind] == 'producer'
  end

  def seyu?
    params[:kind] == 'seyu'
  end
end
