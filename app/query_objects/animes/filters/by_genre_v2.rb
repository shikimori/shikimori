class Animes::Filters::ByGenreV2 < Animes::Filters::ByGenre
  private

  def term_sql term
    "genre_v2_ids && '{#{term.to_i}}'"
  end
end
