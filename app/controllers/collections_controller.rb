class CollectionsController < ShikimoriController
  load_and_authorize_resource :collection, except: %i[index autocomplete]

  before_action { og page_title: i18n_i('Collection', :other) }
  before_action :set_breadcrumbs, except: %i[index autocomplete]
  before_action :resource_redirect, if: :resource_id

  UPDATE_PARAMS = %i[name text tags] + [
    links: %w[linked_id group text]
  ]
  CREATE_PARAMS = %i[user_id kind] + UPDATE_PARAMS

  def index # rubocop:disable AbcSize
    @limit = [[params[:limit].to_i, 4].max, 8].min

    @collection = Collections::Query.fetch(locale_from_host)
      .search(params[:search], locale_from_host)
      .paginate(@page, @limit)
      .transform do |collection|
        Topics::TopicViewFactory
          .new(true, true)
          .build(collection.maybe_topic(locale_from_host))
      end

    if @page == 1 && params[:search].blank? && user_signed_in?
      @unpublished_collections = current_user.collections.unpublished
    end
  end

  def show
    if @resource.unpublished? && cannot?(:edit, @resource)
      raise ActiveRecord::RecordNotFound
    end

    if @resource.unpublished?
      breadcrumb @resource.name, edit_collection_url(@resource)
      breadcrumb t('actions.preview'), nil
    end

    og page_title: @resource.name
    @topic_view = Topics::TopicViewFactory
      .new(false, false)
      .build(@resource.maybe_topic(locale_from_host))
  end

  def tooltip
    og noindex: true
    @topic_view = Topics::TopicViewFactory
      .new(true, true)
      .build(@resource.maybe_topic(locale_from_host))

    if request.xhr?
      render(
        partial: 'topics/topic',
        object: @topic_view,
        as: :topic_view,
        layout: false,
        formats: :html
      )
    else
      render :show
    end
  end

  def new
    og page_title: i18n_t('new_collection')
    render :form
  end

  def create
    @resource = Collection::Create.call create_params, locale_from_host

    if @resource.errors.blank?
      redirect_to edit_collection_url(@resource),
        notice: i18n_t('collection_created')
    else
      new
    end
  end

  def edit
    og page_title: @resource.name
    @section = params[:section]
    render :form
  end

  def update
    collection_update params: update_params
  end

  def to_published
    collection_update transition: :to_published
  end

  def to_private
    collection_update transition: :to_private
  end

  def to_opened
    collection_update transition: :to_opened
  end

  def destroy
    Collection::Destroy.call @resource, current_user

    if request.xhr?
      render json: { notice: i18n_t('collection_deleted') }
    else
      redirect_to collections_url, notice: i18n_t('collection_deleted')
    end
  end

  def autocomplete
    @collection = Collections::Query.fetch(locale_from_host)
      .search(params[:search], locale_from_host)
      .paginate(1, CompleteQuery::AUTOCOMPLETE_LIMIT)
      .reverse
  end

private

  def collection_update transition: nil, params: nil
    Collection::Update.call @resource, params, transition, current_user

    if @resource.errors.blank?
      redirect_to edit_collection_url(@resource), notice: t('changes_saved')
    else
      flash[:alert] = t('changes_not_saved')
      edit
    end
  end

  def set_breadcrumbs
    if @resource&.published?
      set_collections_breadcrumbs
    else
      set_profile_breadcrumbs
    end
  end

  def set_collections_breadcrumbs
    breadcrumb i18n_i('Collection', :other), collections_url

    if %w[edit update].include? params[:action]
      breadcrumb(
        @resource.name,
        @resource.published? ? collection_url(@resource) :
          edit_collection_url(@resource)
      )
      breadcrumb t('actions.edition'), nil
    end
  end

  def set_profile_breadcrumbs # rubocop:disable AbcSize, MethodLength
    owner = @resource.user.decorate

    breadcrumb I18n.t('profiles_controller.user_profile'), profile_url(@resource.user)
    breadcrumb i18n_i('Collection', :other), collections_profile_url(owner)

    if @resource.persisted?
      breadcrumb(
        I18n.t("profiles.page.collections.#{@resource.state}"),
        collections_profile_url(owner, state: @resource.state)
      )
    end

    if %w[new create].include? params[:action]
      breadcrumb i18n_t('new_collection'), nil
    end

    if %w[edit update].include? params[:action]
      breadcrumb @resource.name, collection_url(@resource)
      breadcrumb t('actions.edition'), nil
    end
  end

  def create_params
    collection_params CREATE_PARAMS
  end
  alias new_params create_params

  def update_params
    collection_params UPDATE_PARAMS
  end

  def collection_params permitted_keys
    params
      .require(:collection)
      .permit(*permitted_keys)
      .tap do |fixed_params|
        unless fixed_params[:tags].nil?
          fixed_params[:tags] = fixed_params[:tags].split(',').map(&:strip).select(&:present?)
        end
      end
  end
end
