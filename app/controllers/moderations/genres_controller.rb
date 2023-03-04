class Moderations::GenresController < ModerationsController
  include SortingConcern
  include FixParamsConcern

  skip_before_action :authenticate_user!, only: %i[tooltip]
  load_and_authorize_resource
  before_action :set_breadcrumbs, except: %i[tooltip]

  helper_method :versioned_view

  SORTING_FIELD = :position
  SORTING_ORDER = :asc

  VERSIONS_PER_PAGE = 20

  def index
    @versions = VersionsQuery.by_type(type.capitalize, nil)
      .paginate(@page, VERSIONS_PER_PAGE)
      .lazy_map(&:decorate)

    if json?
      render 'db_entries/versions', locals: { collection: @versions }
    elsif resource_class == Genre
      @collection = @collection.order(:kind, sorting_options)
    else
      @collection = @collection.order(sorting_options)
    end
  end

  def edit
    @versions = VersionsQuery.by_item(@resource, nil)
      .paginate(@page, VERSIONS_PER_PAGE)
      .lazy_map(&:decorate)

    render 'db_entries/versions', locals: { collection: @versions } if json?
  end

  def update # rubocop:disable all
    versions = []

    versions.push(
      Versioneers::FieldsVersioneer
        .new(@resource)
        .postmoderate(update_params.to_unsafe_h.except(:image), current_user)
    )

    if update_params[:image]
      versions.push(
        Versioneers::PostersOldVersioneer
          .new(@resource)
          .postmoderate(update_params[:image], current_user)
      )
    end

    if versions.any?(&:persisted?)
      redirect_to index_url
    else
      redirect_back(
        fallback_location: edit_url(@resource),
        alert: versions.map { |v| v.errors[:base]&.dig(0) }.compact.first || i18n_t('no_changes')
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
