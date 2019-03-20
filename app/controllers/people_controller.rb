# rubocop:disable ClassLength
class PeopleController < DbEntriesController
  respond_to :html, only: %i[show tooltip]
  respond_to :html, :json, only: :index
  respond_to :json, only: :autocomplete

  before_action :resource_redirect, if: :resource_id
  before_action :set_breadcrumbs, if: -> { @resource }
  before_action :js_export, only: %i[show]

  helper_method :search_url
  # caches_action :index, :page, :show, :tooltip, CacheHelper.cache_settings

  PER_PAGE = 48

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
  end

  def works
    og noindex: true
    og page_title: i18n_t('participation_in_projects')
  end

  def roles
    og noindex: true
    og page_title: i18n_t('roles_in_anime')
  end

  def favoured
    return redirect_to @resource.url, status: 301 if @resource.all_favoured.none?

    og noindex: true
    og page_title: t('in_favorites')
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
      is_seyu: seyu?,
      is_mangaka: mangaka?,
      is_producer: producer?
    }
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

  def set_breadcrumbs
    breadcrumb i18n_t('all_people'), people_url

    breadcrumb i18n_t('producers'), producers_people_url if @resource.producer?
    breadcrumb i18n_t('mangakas'), mangakas_people_url if @resource.mangaka?
    breadcrumb i18n_t('seyu'), seyu_people_url if @resource.seyu?

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

  # rubocop:disable MethodLength
  def js_export
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
  # rubocop:enable MethodLength

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
# rubocop:enable ClassLength
