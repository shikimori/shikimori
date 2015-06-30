describe UserRatesQuery do
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:user4) { create :user }
  let(:entry) { create :anime }

  before do
    create :friend_link, src: user, dst: user2
    create :friend_link, src: user, dst: user3
    create :user_rate, user: user2, target: entry, score: 9, status: 1
    create :user_rate, user: user3, target: entry, score: 5
    create :user_rate, user: user4, target: entry, score: 9
  end
  let(:query) { UserRatesQuery.new(entry, user) }

  describe '#friend_rates' do
    subject { query.friend_rates }
    it { should have(2).items  }
  end

  describe '#recent_rates' do
    it { expect(query.recent_rates(100)).to have(3).items  }
    it { expect(query.recent_rates(1)).to have(1).item  }
  end

  describe '#statuses_stats' do
    subject { query.statuses_stats }
    it { should eq(0 => 2, 1 => 1) }
  end

  describe '#scores_stats' do
    subject { query.scores_stats }
    it { should eq(9 => 2, 5 => 1) }
  end
end
