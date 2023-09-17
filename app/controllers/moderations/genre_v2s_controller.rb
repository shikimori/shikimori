class Moderations::GenreV2sController < Moderations::GenresController
  def update_params
    params
      .require(:genre_v2)
      .permit(*FIELDS)
  end

  def index_url
    moderations_genre_v2s_url
  end

  def sorting_options type = GenreV2
    [
      build_sort(sorting_field(type), sorting_order(type)),
      build_sort(genres_sort_key, :asc),
      build_sort(:entry_type, :asc)
    ]
  end
end
