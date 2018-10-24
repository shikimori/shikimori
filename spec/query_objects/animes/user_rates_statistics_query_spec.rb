describe Animes::UserRatesStatisticsQuery do
  let(:user_4) { seed :user_admin }
  let(:entry) { create :anime }

  let!(:user_rate_1) { create :user_rate, :watching, user: user_2, target: entry, score: 9 }
  let!(:user_rate_2) { create :user_rate, :planned, user: user_3, target: entry, score: 5 }
  let!(:user_rate_3) { create :user_rate, :planned, user: user_4, target: entry, score: 9 }
  let!(:user_rate_4) { create :user_rate, :completed, user: create(:user), target: entry }
  let!(:user_rate_5) { create :user_rate, :rewatching, user: create(:user), target: entry }

  let(:query) { Animes::UserRatesStatisticsQuery.new(entry, user) }

  describe '#friend_rates' do
    let!(:friend_link_1) { create :friend_link, src: user, dst: user_2 }
    let!(:friend_link_2) { create :friend_link, src: user, dst: user_3 }
    subject { query.friend_rates }

    it { is_expected.to have(2).items }
  end

  # describe '#recent_rates' do
    # it { expect(query.recent_rates(100)).to have(3).items  }
    # it { expect(query.recent_rates(1)).to have(1).item  }
  # end

  describe '#statuses_stats' do
    subject { query.statuses_stats }
    it { is_expected.to eq 'completed' => 2, 'planned' => 2, 'watching' => 1 }
  end

  describe '#scores_stats' do
    subject { query.scores_stats }
    it { is_expected.to eq 9 => 2, 5 => 1 }
  end
end
