describe Queries::CharactersQuery do
  include_context :graphql

  let(:query_string) do
    <<~GQL
      {
        characters {
          id
          name
        }
      }
    GQL
  end
  let!(:character) { create :character, id: 99999 }
  let!(:character_2) { create :character, id: 88888 }

  it do
    is_expected.to eq(
      'characters' => [{
        'id' => character_2.id.to_s,
        'name' => character_2.name
      }, {
        'id' => character.id.to_s,
        'name' => character.name
      }]
    )
  end

  context 'ids' do
    let(:query_string) do
      <<~GQL
        query($ids: [ID!]) {
          characters(ids: $ids) {
            id
            name
          }
        }
      GQL
    end
    let(:variables) { { ids: [character.id] } }

    it do
      is_expected.to eq(
        'characters' => [{
          'id' => character.id.to_s,
          'name' => character.name
        }]
      )
    end
  end
end
