class SectionsController < ModerationsController
  load_and_authorize_resource
  before_action :set_breadcrumbs

  def index
    @collection = @collection.order({is_visible: :desc}, :position)
  end

  def edit
  end

  def update
    if @resource.update update_params
      redirect_to sections_url
    else
      render action: 'edit'
    end
  end

private

  def update_params
    params.require(:section).permit(:position, :permalink, :is_visible)
  end

  def set_breadcrumbs
    page_title t('.sections')
    page_title @resource.name if @resource
    breadcrumb t('.sections'), sections_url if @resource
  end
end
