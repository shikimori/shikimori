describe Queries::AnimesQuery do
  include_context :graphql

  subject { data['items'] }
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
  let!(:anime) { create :anime }
  let!(:anime_2) { create :anime }

  it do
    is_expected.to eq [{
      'id' => anime.id,
      'name' => anime.name
    }, {
      'id' => anime_2.id,
      'name' => anime_2.name
    }]
  end
end
