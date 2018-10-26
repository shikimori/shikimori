describe Achievements::Statistics do
  subject { described_class.call neko_id, level }
  let(:neko_id) { Types::Achievement::NekoId[:test] }
  let(:level) { 1 }

  let!(:pg_cache_data) do
    create :pg_cache_data,
      key: described_class::CACHE_KEY,
      value: YAML.dump(cache)
  end

  context 'has cache' do
    let(:cache) do
      {
        described_class::TOTAL_KEY => {
          described_class::TOTAL_LEVEL => Neko::Stats.new(
            'interval_0' => 600,
            'interval_1' => 500,
            'interval_2' => 400,
            'interval_3' => 300,
            'interval_4' => 200,
            'interval_5' => 100,
            'interval_6' => 10
          )
        },
        test: {
          '1': Neko::Stats.new(
            'interval_0' => 0,
            'interval_1' => 1,
            'interval_2' => 2,
            'interval_3' => 3,
            'interval_4' => 4,
            'interval_5' => 5,
            'interval_6' => 6
          )
        }
      }
    end

    it do
      is_expected.to eq(
        [
          {
            label: '0-50',
            users: 0,
            percent: 0.0
          }, {
            label: '51-100',
            users: 1,
            percent: 0.002
          }, {
            label: '101-250',
            users: 2,
            percent: 0.005
          }, {
            label: '251-400',
            users: 3,
            percent: 0.01
          }, {
            label: '401-600',
            users: 4,
            percent: 0.02
          }, {
            label: '601-1000',
            users: 5,
            percent: 0.05
          }, {
            label: '1000+',
            users: 6,
            percent: 0.6
          }
        ]
      )
    end
  end

  context 'no cache' do
    let(:cache) { {} }
    it { is_expected.to be_nil }
  end
end
