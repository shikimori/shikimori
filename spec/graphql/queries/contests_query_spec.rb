describe Queries::ContestsQuery do
  include_context :graphql

  let(:query_string) do
    <<~GQL
      {
        contests {
          id
          name
        }
      }
    GQL
  end
  let!(:contest) { create :contest, id: 99999 }
  let!(:contest_2) { create :contest, id: 88888 }

  it do
    is_expected.to eq(
      'contests' => [{
        'id' => contest.id.to_s,
        'name' => contest.name
      }, {
        'id' => contest_2.id.to_s,
        'name' => contest_2.name
      }]
    )
  end

  context 'ids' do
    let(:query_string) do
      <<~GQL
        query($ids: [ID!]) {
          contests(ids: $ids) {
            id
            name
          }
        }
      GQL
    end
    let(:variables) { { ids: [contest.id] } }

    it do
      is_expected.to eq(
        'contests' => [{
          'id' => contest.id.to_s,
          'name' => contest.name
        }]
      )
    end
  end
end
