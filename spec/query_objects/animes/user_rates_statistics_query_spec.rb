describe Animes::UserRatesStatisticsQuery do
  let(:user_4) { seed :user_admin }
  let(:user_5) { create :user }
  let(:user_6) { create :user }
  let(:cheat_bot) { create :user, :cheat_bot }
  let(:entry) { create :anime }

  let!(:user_rate_1) do
    create :user_rate, :watching, user: user_2, target: entry, score: 9
  end
  let!(:user_rate_2) do
    create :user_rate, :planned, user: user_3, target: entry, score: 5
  end
  let!(:user_rate_3) do
    create :user_rate, :planned, user: user_4, target: entry, score: 9
  end
  let!(:user_rate_4) do
    create :user_rate, :completed, user: user_5, target: entry
  end
  let!(:user_rate_5) do
    create :user_rate, :rewatching, user: user_6, target: entry
  end
  let!(:user_rate_6) do
    create :user_rate, :rewatching, user: cheat_bot, target: entry, score: 9
  end

  let(:query) { described_class.new(entry, user) }

  describe '#friend_rates' do
    let!(:friend_link_1) { create :friend_link, src: user, dst: user_2 }
    let!(:friend_link_2) { create :friend_link, src: user, dst: user_3 }
    subject { query.friend_rates }

    it { is_expected.to have(2).items }
  end
end
