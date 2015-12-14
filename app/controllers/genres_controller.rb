class GenresController < ShikimoriController
  load_and_authorize_resource
  # before_action :authenticate_user!, except: [:index, :tooltip]
  before_action :set_breadcrumbs, except: :index

  def index
    @collection = @collection.order(:kind, :position, :name)
  end

  def edit
  end

  def update
    if @resource.update genre_params
      redirect_to genres_url, notice: 'Genre updated'
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
    breadcrumb 'Genres', genres_url
  end
end
