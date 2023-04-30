class GenresV2Repository < RepositoryBase
  def by_mal_id mal_id
    collection.values.find { |genre| genre.mal_id == mal_id } ||
      (reset && collection.values.find { |genre| genre.mal_id == mal_id }) ||
      raise(ActiveRecord::RecordNotFound)
  end

private

  def scope
    GenreV2.order(:position)
  end
end
