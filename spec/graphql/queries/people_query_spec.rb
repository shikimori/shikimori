describe Queries::PeopleQuery do
  include_context :graphql

  let(:query_string) do
    <<~GQL
      {
        people {
          id
          name
        }
      }
    GQL
  end
  let!(:person) { create :person, id: 99999 }
  let!(:person_2) { create :person, id: 88888 }

  it do
    is_expected.to eq(
      'people' => [{
        'id' => person_2.id.to_s,
        'name' => person_2.name
      }, {
        'id' => person.id.to_s,
        'name' => person.name
      }]
    )
  end

  context 'ids' do
    let(:query_string) do
      <<~GQL
        query($ids: [ID!]) {
          people(ids: $ids) {
            id
            name
          }
        }
      GQL
    end
    let(:variables) { { ids: [person.id] } }

    it do
      is_expected.to eq(
        'people' => [{
          'id' => person.id.to_s,
          'name' => person.name
        }]
      )
    end
  end
end
