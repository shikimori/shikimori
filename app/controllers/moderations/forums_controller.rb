class Moderations::ForumsController < ModerationsController
  load_and_authorize_resource
  before_action :set_breadcrumbs

  def index
    @collection = @collection.order(:position)
  end

  def edit
  end

  def update
    if @resource.update update_params
      redirect_to moderations_forums_url
    else
      render action: 'edit'
    end
  end

private

  def update_params
    params.require(:forum).permit(:position, :name_ru, :name_en, :permalink)
  end

  def set_breadcrumbs
    og page_title: t('.forums')
    og page_title: @resource.name if @resource
    breadcrumb t('.forums'), moderations_forums_url if @resource
  end
end
