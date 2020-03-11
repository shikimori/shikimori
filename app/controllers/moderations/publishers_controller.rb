class Moderations::PublishersController < Moderations::GenresController
  ORDER_FIELDS = %i[name]

private

  def update_params
    params
      .require(:publisher)
      .permit(:name)
  end
end
