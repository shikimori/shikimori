describe Queries::UsersQuery do
  include_context :graphql

  before { User.delete_all }
  let(:query_string) do
    <<~GQL
      {
        users {
          id
          nickname
        }
      }
    GQL
  end
  let!(:user) { create :user, id: 99999 }
  let!(:user_2) { create :user, id: 88888 }

  it do
    is_expected.to eq(
      'users' => [{
        'id' => user.id.to_s,
        'nickname' => user.nickname
      }, {
        'id' => user_2.id.to_s,
        'nickname' => user_2.nickname
      }]
    )
  end

  context 'ids' do
    let(:query_string) do
      <<~GQL
        query($ids: [ID!]) {
          users(ids: $ids) {
            id
            nickname
          }
        }
      GQL
    end
    let(:variables) { { ids: [user.id] } }

    it do
      is_expected.to eq(
        'users' => [{
          'id' => user.id.to_s,
          'nickname' => user.nickname
        }]
      )
    end
  end
end
