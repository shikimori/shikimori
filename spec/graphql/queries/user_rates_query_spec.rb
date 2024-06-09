describe Queries::UserRatesQuery do
  include_context :graphql

  let(:query_string) do
    <<~GQL
      query(
        $page: Int,
        $limit: PositiveInt,
        $userId: ID,
        $targetType: UserRateTargetTypeEnum!
        $status: UserRateStatusEnum
        $order: UserRateOrderInputType
      ) {
        userRates(
          page: $page,
          limit: $limit,
          userId: $userId,
          targetType: $targetType,
          status: $status,
          order: $order
        ) {
          id
        }
      }
    GQL
  end
  let!(:user_rate_1) { create :user_rate, user:, target: create(:anime) }
  let!(:user_rate_2) { create :user_rate, :watching, user:, target: create(:anime) }
  let!(:user_rate_3) { create :user_rate, user:, target: create(:manga) }
  let!(:user_rate_4) { create :user_rate, user: user_2, target: create(:anime) }

  let(:variables) do
    {
      targetType: 'Anime'
    }
  end
  let(:context) { { current_user: user } }

  it do
    is_expected.to eq(
      'userRates' => [{
        'id' => user_rate_1.id.to_s
      }, {
        'id' => user_rate_2.id.to_s
      }]
    )
  end

  context 'page + limit' do
    let(:variables) do
      {
        page: 1,
        limit: 1,
        targetType: 'Anime'
      }
    end

    it do
      is_expected.to eq(
        'userRates' => [{
          'id' => user_rate_1.id.to_s
        }]
      )
    end
  end

  context 'target_type' do
    let(:variables) do
      {
        targetType: 'Manga'
      }
    end

    it do
      is_expected.to eq(
        'userRates' => [{
          'id' => user_rate_3.id.to_s
        }]
      )
    end
  end

  context 'status' do
    let(:variables) do
      {
        targetType: 'Anime',
        status: 'watching'
      }
    end

    it do
      is_expected.to eq(
        'userRates' => [{
          'id' => user_rate_2.id.to_s
        }]
      )
    end
  end

  context 'user_id' do
    let(:variables) do
      {
        targetType: 'Anime',
        userId: user_2.id
      }
    end

    it do
      is_expected.to eq(
        'userRates' => [{
          'id' => user_rate_4.id.to_s
        }]
      )
    end
  end

  context 'order' do
    let(:variables) do
      {
        targetType: 'Anime',
        order: { field: 'id', order: 'desc' }
      }
    end

    it do
      is_expected.to eq(
        'userRates' => [{
          'id' => user_rate_2.id.to_s
        }, {
          'id' => user_rate_1.id.to_s
        }]
      )
    end
  end

  context 'no current_user' do
    let(:context) { {} }

    it do
      is_expected.to eq 'userRates' => []
    end
  end
end
