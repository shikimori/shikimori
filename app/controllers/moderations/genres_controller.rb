class Moderations::GenresController < ModerationsController
  skip_before_action :authenticate_user!, only: %i[tooltip]
  load_and_authorize_resource
  before_action :set_breadcrumbs, except: %i[tooltip]

  helper_method :versioned_view

  ORDER_FIELDS = %i[kind position name]
  VERSIONS_LIMIT = 20

  def index
    @versions = VersionsQuery.by_type(type.capitalize)
      .paginate(@page, VERSIONS_LIMIT)
      .transform(&:decorate)

    if json?
      render 'db_entries/versions', collection: @versions
    else
      @collection = @collection.order(*self.class::ORDER_FIELDS)
    end
  end

  def edit
    @versions = VersionsQuery.by_item(@resource)
      .paginate(@page, VERSIONS_LIMIT)
      .transform(&:decorate)

    render 'db_entries/versions', collection: @versions if json?
  end

  def update
    version = Versioneers::FieldsVersioneer
      .new(@resource)
      .postmoderate(
        update_params.is_a?(Hash) ? update_params : update_params.to_unsafe_h,
        current_user,
        ''
      )

    if version.persisted?
      redirect_to index_url
    else
      redirect_back(
        fallback_location: edit_url(@resource),
        alert: version.errors[:base]&.dig(0) || i18n_t('no_changes')
      )
    end
  end

  def tooltip
    og noindex: true, nofollow: true
  end

private

  def update_params
    params
      .require(:genre)
      .permit(:name, :russian, :position, :seo, :description)
  end

  def type
    self.class.name.split('::')[1].gsub('Controller', '').downcase.singularize
  end

  def index_url
    send :"moderations_#{type.pluralize}_url"
  end

  def edit_url resource
    send :"moderations_#{type}_url", resource
  end

  def set_breadcrumbs
    og page_title: i18n_io(type.capitalize, :few)
    og page_title: @resource.name if @resource

    breadcrumb i18n_io(type.capitalize, :few), index_url if @resource
  end
end
