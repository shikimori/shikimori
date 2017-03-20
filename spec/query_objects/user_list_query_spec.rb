describe UserListQuery do
  let(:query) { UserListQuery.new Anime, user, params }
  let(:user) { create :user }
  let(:params) { { mylist: '1,2', order: 'name' } }

  let!(:user_rate_1) { create :user_rate, user: user, anime: create(:anime, name: 'b'), status: 1 }
  let!(:user_rate_2) { create :user_rate, user: user, anime: create(:anime, name: 'a'), status: 1 }
  let!(:user_rate_3) { create :user_rate, user: user, anime: create(:anime), status: 2 }
  let!(:user_rate_4) { create :user_rate, user: user, anime: create(:anime), status: 3 }

  describe '#fetch' do
    subject { query.fetch }

    it { is_expected.to have(2).items }
    its(:first) { is_expected.to eq [:watching, [user_rate_2, user_rate_1]] }
    its([:completed]) { is_expected.to eq [user_rate_3] }
  end
end
