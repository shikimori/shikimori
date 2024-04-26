describe Queries::GenresQuery do
  include_context :graphql
  # include_context :reset_repository, AnimeGenresV2Repository

  let(:query_string) do
    <<~GQL
      query(
        $entryType: GenreEntryTypeEnum!
      ) {
        genres(
          entryType: $entryType,
        ) {
          id
          name
          russian
          kind
          entryType
        }
      }
    GQL
  end

  let(:variables) do
    {
      entryType: Types::GenreV2::EntryType['Anime']
    }
  end
  let!(:anime_genre_v1) { create :genre, :anime }
  let!(:anime_genre_v2) { create :genre_v2, :anime }
  let!(:manga_genre_v2) { create :genre_v2, :manga }

  it do
    is_expected.to eq(
      'genres' => [{
        'id' => anime_genre_v2.id.to_s,
        'name' => anime_genre_v2.name,
        'russian' => anime_genre_v2.russian,
        'kind' => Types::GenreV2::Kind[:genre].to_s,
        'entryType' => Types::GenreV2::EntryType['Anime']
      }]
    )
  end
end
