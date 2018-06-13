describe Achievements::UpdateStatistics do
  subject { described_class.new.perform }

  before do
    allow(Rails.application.redis).to receive :set
  end

  let(:neko_id) { Types::Achievement::NekoId[:test] }
  let(:level) { 1 }

  let!(:achievement_1) do
    create :achievement,
      neko_id: neko_id,
      level: level,
      user: user_1
  end
  let!(:achievement_2) do
    create :achievement,
      neko_id: neko_id,
      level: level,
      user: user_2
  end
  let(:user_1) { seed :user }
  let(:user_2) { create :user }

  let!(:user_rate_1) { create :user_rate, :completed, target: anime, user: user_1 }
  let!(:user_rate_2) { create :user_rate, :completed, target: anime, user: user_2 }
  let(:anime) { build_stubbed :anime }

  let(:statistics) do
    {
      Achievements::Statistics::TOTAL_KEY => {
        Achievements::Statistics::TOTAL_LEVEL =>
          Neko::Stats.new(interval_0: 2)
      },
      neko_id.to_sym => {
        level.to_s.to_sym => Neko::Stats.new(interval_0: 2)
      }
    }
  end

  it do
    is_expected.to eq statistics
    expect(Rails.application.redis)
      .to have_received(:set)
      .with Achievements::Statistics::CACHE_KEY, statistics.to_json
  end
end
