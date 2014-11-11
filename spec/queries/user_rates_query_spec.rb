describe UserRatesQuery do
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:user4) { create :user }
  let(:entry) { create :anime }

  before do
    create :friend_link, src: user, dst: user2
    create :friend_link, src: user, dst: user3
    create :user_rate, user: user2, target: entry
    create :user_rate, user: user3, target: entry
    create :user_rate, user: user4, target: entry
  end
  let(:query) { UserRatesQuery.new(entry, user) }

  describe 'friend_rates' do
    it { query.friend_rates.should have(2).items  }
  end

  describe 'recent_rates' do
    it { query.recent_rates(100).should have(3).items  }
    it { query.recent_rates(1).should have(1).item  }
  end
end
