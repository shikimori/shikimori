class GenresController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    noindex && nofollow
    @collection = Genre.order(:position, :name)
  end

  def edit
    raise Forbidden unless current_user.moderator?
    @resource = Genre.find params[:id]
  end

  def update
    raise Forbidden unless current_user.moderator?
    @resource = Genre.find params[:id]

    if @resource.update genre_params
      redirect_to genres_url, notice: 'Описание жанра обновлено'
    else
      render action: 'edit'
    end
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
