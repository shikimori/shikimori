describe Recommendations::Metrics::AvgScore do
  let(:metric) { Recommendations::Metrics::AvgScore.new }
  let(:all_rates) do
    {
      user_1: {
        sample_1: 1,
        sample_2: 3
      },
      user_2: {
        sample_1: 9,
        sample_2: 9
      }
    }
  end

  describe '#predict' do
    before { metric.learn :user_1, all_rates[:user_1], all_rates[:user_1], all_rates }
    it { expect(metric.predict :user_1, 10, true).to eq sample_1: 5, sample_2: 6 }
  end
end
