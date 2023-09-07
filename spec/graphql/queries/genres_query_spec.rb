describe Queries::GenresQuery do
  include_context :graphql

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
  let!(:anime_genre) { create :genre, :anime }
  let!(:manga_genre) { create :genre, :manga }

  it do
    is_expected.to eq(
      'genres' => [{
        'id' => anime_genre.id.to_s,
        'name' => anime_genre.name,
        'russian' => anime_genre.russian,
        'kind' => Types::GenreV2::Kind[:genre].to_s,
        'entryType' => Types::GenreV2::EntryType['Anime']
      }]
    )
  end
end
