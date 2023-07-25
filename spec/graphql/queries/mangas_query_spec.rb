describe Queries::MangasQuery do
  include_context :graphql

  let(:query_string) do
    <<~GQL
      {
        mangas {
          id
          name
        }
      }
    GQL
  end
  let!(:manga) { create :manga, ranked: 2 }
  let!(:manga_2) { create :manga, ranked: 1 }

  it do
    is_expected.to eq(
      'mangas' => [{
        'id' => manga_2.id.to_s,
        'name' => manga_2.name
      }, {
        'id' => manga.id.to_s,
        'name' => manga.name
      }]
    )
  end
end
