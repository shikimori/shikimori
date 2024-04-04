class Queries::GenresQuery < Queries::BaseQuery
  type [Types::GenreType], null: false

  argument :entry_type, Types::Enums::Genre::EntryTypeEnum, required: true

  def resolve entry_type:
    repository_klass = entry_type == Types::GenreV2::EntryType['Anime'] ?
      AnimeGenresV2Repository :
      MangaGenresV2Repository

    repository_klass.instance.to_a
  end
end
