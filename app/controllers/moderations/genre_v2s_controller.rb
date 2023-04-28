class Moderations::GenreV2sController < Moderations::GenresController
  def update_params
    params
      .require(:genre_v2)
      .permit(*FIELDS)
  end
end
