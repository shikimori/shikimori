describe UserRatesQuery do
  let(:user_2) { create :user }
  let(:user_3) { create :user }
  let(:user_4) { create :user }
  let(:entr_cy) { create :anime }

  before do
    create :friend_link, src: user, dst: user_2
    create :friend_link, src: user, dst: user_3
    create :user_rate, user: user_2, target: entry, score: 9, status: :watching
    create :user_rate, user: user_3, target: entry, score: 5
    create :user_rate, user: user_4, target: entry, score: 9
  end
  let(:query) { UserRatesQuery.new(entry, user) }

  describe '#friend_rates' do
    subject { query.friend_rates }
    it { is_expected.to have(2).items }
  end

  # describe '#recent_rates' do
    # it { expect(query.recent_rates(100)).to have(3).items  }
    # it { expect(query.recent_rates(1)).to have(1).item  }
  # end

  describe '#statuses_stats' do
    subject { query.statuses_stats }
    it { is_expected.to eq 'planned' => 2, 'watching' => 1 }
  end

  describe '#scores_stats' do
    subject { query.scores_stats }
    it { is_expected.to eq 9 => 2, 5 => 1 }
  end
end
