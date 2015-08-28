class GenresController < ShikimoriController
  before_action :authenticate_user!, except: [:index, :tooltip]

  def index
    noindex && nofollow
    @kind = params[:kind] || 'anime'
    @collection = Genre.where(kind: @kind).order(:position, :name)
  end

  def edit
    raise Forbidden unless current_user.moderator?
    @resource = Genre.find params[:id]
  end

  def update
    raise Forbidden unless current_user.moderator?
    @resource = Genre.find params[:id]

    if @resource.update genre_params
      redirect_to index_genres_url(kind: @resource.kind), notice: 'Описание жанра обновлено'
    else
      render action: 'edit'
    end
  end

  def tooltip
    noindex && nofollow
    @resource = Genre.find params[:id]
  end

private

  def genre_params
    if current_user.admin?
      params.require(:genre).permit(:name, :russian, :position, :seo, :description)
    else
      params.require(:genre).permit(:description)
    end
  end
end
