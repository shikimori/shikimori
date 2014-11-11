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
    it { expect(query.friend_rates.size).to eq(2)  }
  end

  describe 'recent_rates' do
    it { expect(query.recent_rates(100).size).to eq(3)  }
    it { expect(query.recent_rates(1).size).to eq(1)  }
  end
end
