describe UserListQuery do
  subject do
    described_class.call(
      klass: Anime,
      user: user,
      params: params
    )
  end
  let(:params) { { mylist: '1,2', order: 'name' } }

  let!(:user_rate_1) do
    create :user_rate,
      user: user,
      anime: create(:anime, name: 'b'),
      status: 1
  end
  let!(:user_rate_2) do
    create :user_rate,
      user: user,
      anime: create(:anime, name: 'a'),
      status: 1
  end
  let!(:user_rate_3) do
    create :user_rate,
      user: user,
      anime: create(:anime),
      status: 2
  end
  let!(:user_rate_4) do
    create :user_rate,
      user: user,
      anime: create(:anime),
      status: 3
  end

  it do
    is_expected.to eq(
      watching: [
        UserRates::StructEntry.create(user_rate_2),
        UserRates::StructEntry.create(user_rate_1)
      ],
      completed: [
        UserRates::StructEntry.create(user_rate_3)
      ]
    )
  end
end
