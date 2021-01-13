describe UserListQuery do
  subject { described_class.call Anime, user, params }
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
    is_expected.to have(2).items
    expect(subject.first).to eq [:watching, [user_rate_2, user_rate_1]]
    expect(subject[:completed]).to eq [user_rate_3]
  end
end
