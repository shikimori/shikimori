class Moderations::StudiosController < Moderations::GenresController
  SORTING_FIELD = :id

private

  def update_params
    params
      .require(:studio)
      .permit(:name, :image, :is_visible)
      .tap do |allowed_params|
        allowed_params[:is_visible] = allowed_params[:is_visible] != '0'
      end
  end
end
