describe Achievements::Statistics do
  subject { Achievements::Statistics.call neko_id, level }
  let(:neko_id) { Types::Achievement::NekoId[:test] }
  let(:level) { 1 }

  before do
    allow(Rails.application.redis)
      .to receive(:get)
      .with(Achievements::Statistics::CACHE_KEY)
      .and_return cache
  end

  context 'has cache' do
    let(:cache) do
      {
        'test' => {
          '1' => {
            'interval_0' => 1,
            'interval_1' => 2,
            'interval_2' => 3,
            'interval_3' => 4,
            'interval_4' => 5,
            'interval_5' => 6,
            'interval_6' => 7
          }
        }
      }.to_json
    end
    it do
      is_expected.to be_kind_of Neko::Statistics
    end
  end

  context 'no cache' do
    let(:cache) { [{}.to_json, nil].sample }
    it { is_expected.to be_nil }
  end
end
