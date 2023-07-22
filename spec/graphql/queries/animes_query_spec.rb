describe Queries::AnimesQuery do
  include_context :graphql

  let(:query_string) do
    <<~GQL
      {
        animes {
          id
          name
        }
      }
    GQL
  end
  let!(:anime) { create :anime, ranked: 2 }
  let!(:anime_2) { create :anime, ranked: 1 }

  it do
    is_expected.to eq(
      'animes' => [{
        'id' => anime_2.id.to_s,
        'name' => anime_2.name
      }, {
        'id' => anime.id.to_s,
        'name' => anime.name
      }]
    )
  end
end
