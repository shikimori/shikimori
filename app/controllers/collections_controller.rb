class CollectionsController < ShikimoriController
  load_and_authorize_resource :collection, except: %i[index show]

  before_action { page_title i18n_i('Collection', :other) }
  before_action :set_breadcrumbs, except: :index

  UPDATE_PARAMS = %i(name text)
  CREATE_PARAMS = %i(user_id kind) + UPDATE_PARAMS

  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 24].max, 48].min

    @collection, @add_postloader = CollectionsQuery
      .new(locale_from_host)
      .postload(@page, @limit)
  end

  def show
  end

  def new
    page_title i18n_t('new_collection')
    render :form
  end

  def create
    @resource = Collection::Create.call create_params, locale_from_host

    if @resource.errors.blank?
      redirect_to collection_url(@resource),
        notice: i18n_t('collection_created')
    else
      new
    end
  end

  def edit
    page_title t(:settings)
    @page = params[:page]
    render :form
  end

  def update
    Collection::Update.call @resource, update_params

    if @resource.errors.blank?
      redirect_to collection_url(@resource), notice: t('changes_saved')
    else
      flash[:alert] = t('changes_not_saved')
      edit
    end
  end


private

  def set_breadcrumbs
    breadcrumb i18n_i('Collection', :other), collections_url
  end

  def create_params
    params.require(:collection).permit(*CREATE_PARAMS)
  end
  alias new_params create_params

  def update_params
    params.require(:collection).permit(*UPDATE_PARAMS)
  end
end
