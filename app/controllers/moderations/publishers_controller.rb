class Moderations::PublishersController < Moderations::GenresController
  ORDER_FIELD = :id

private

  def update_params
    params
      .require(:publisher)
      .permit(:name)
  end
end
