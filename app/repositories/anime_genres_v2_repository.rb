class AnimeGenresV2Repository < RepositoryBase
  def by_mal_id mal_id
    collection.values.find { |genre| genre.mal_id == mal_id } ||
      (reset && collection.values.find { |genre| genre.mal_id == mal_id }) ||
      raise(ActiveRecord::RecordNotFound)
  end

  def by_name name
    collection.values.find { |genre| genre.name == name } ||
      (reset && collection.values.find { |genre| genre.name == name }) ||
      raise(ActiveRecord::RecordNotFound)
  end

private

  def scope
    GenreV2.where(entry_type: scope_entry_type).order(:position)
  end

  def scope_entry_type
    Types::GenreV2::EntryType['Anime']
  end
end
