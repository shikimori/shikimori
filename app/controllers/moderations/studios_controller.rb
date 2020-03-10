class Moderations::StudiosController < ModerationsController
  skip_before_action :authenticate_user!, only: %i[tooltip]
  load_and_authorize_resource
  before_action :set_breadcrumbs, except: %i[tooltip]

  helper_method :versioned_view

  def index
    @collection = @collection.order(:name)
  end

  def edit
  end

  def update
    version = Versioneers::FieldsVersioneer
      .new(@resource)
      .postmoderate(
        studio_params.is_a?(Hash) ? studio_params : studio_params.to_unsafe_h,
        current_user,
        ''
      )

    if version.persisted?
      redirect_to moderations_studios_url
    else
      redirect_back(
        fallback_location: moderations_studio_url(@resource),
        alert: version.errors[:base]&.dig(0) || i18n_t('no_changes')
      )
    end
  end

private

  def versioned_view
    @versioned_view ||= VersionedView.new @resource
  end

  def studio_params
    params
      .require(:studio)
      .permit(:name, :is_visible)
      .tap do |allowed_params|
        allowed_params[:is_visible] = allowed_params[:is_visible] != '0'
      end
  end

  def set_breadcrumbs
    og page_title: i18n_io('Studio', :few)
    og page_title: @resource.name if @resource

    breadcrumb i18n_io('Studio', :few), moderations_studios_url if @resource
  end
end
