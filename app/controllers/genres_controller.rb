class GenresController < ApplicationController
  before_action :authenticate_user!

  def index
    raise Forbidden unless current_user.admin?
    @collection = Genre.order(:position, :name)
  end

  def edit
    raise Forbidden unless current_user.admin?
    @resource = Genre.find params[:id]
  end

  def update
    raise Forbidden unless current_user.admin?
    @resource = Genre.find params[:id]

    if @resource.update genre_params
      redirect_to genres_url, notice: 'Genre was successfully updated.'
    else
      render action: 'edit'
    end
  end

private
  def genre_params
    params.require(:genre).permit(:name, :russian, :position, :seo, :description)
  end
end
