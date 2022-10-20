describe Achievements::UpdateStatistics do
  subject { described_class.new.perform }

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

  let!(:user_rate_1) { create :user_rate, :completed, anime: anime, user: user_1 }
  let!(:user_rate_2) { create :user_rate, :completed, anime: anime, user: user_2 }
  let(:anime) { create :anime }

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
    expect(PgCache.read(Achievements::Statistics::CACHE_KEY).deep_symbolize_keys)
      .to eq JSON.parse(statistics.to_json, symbolize_names: true)
  end
end
