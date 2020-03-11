class Moderations::PublishersController < ModerationsController
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
        publisher_params.is_a?(Hash) ? publisher_params : publisher_params.to_unsafe_h,
        current_user,
        ''
      )

    if version.persisted?
      redirect_to moderations_publishers_url
    else
      redirect_back(
        fallback_location: moderations_publisher_url(@resource),
        alert: version.errors[:base]&.dig(0) || i18n_t('no_changes')
      )
    end
  end

private

  def versioned_view
    @versioned_view ||= VersionedView.new @resource
  end

  def publisher_params
    params
      .require(:publisher)
      .permit(:name)
  end

  def set_breadcrumbs
    og page_title: i18n_io('Publisher', :few)
    og page_title: @resource.name if @resource

    breadcrumb i18n_io('Publisher', :few), moderations_publishers_url if @resource
  end
end
