class GenresController < ModerationsController
  load_and_authorize_resource
  before_action :set_breadcrumbs, except: [:tooltip]

  def index
    @collection = @collection.order(:kind, :position, :name)
  end

  def edit
  end

  def update
    if @resource.update genre_params
      redirect_to genres_url
    else
      render action: 'edit'
    end
  end

  def tooltip
    noindex && nofollow
  end

private

  def genre_params
    if current_user.admin?
      params.require(:genre).permit(:name, :russian, :position, :seo, :description)
    else
      params.require(:genre).permit(:description)
    end
  end

  def set_breadcrumbs
    page_title t('.genres')
    page_title "#{@resource.name} / #{@resource.russian}" if @resource

    breadcrumb t('.genres'), genres_url if @resource
  end
end
