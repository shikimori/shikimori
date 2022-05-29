describe Animes::RefreshStats::FilterScores do
  subject do
    described_class.call(
      score: score,
      amount: amount,
      options: options
    )
  end
  let(:score) { 10 }
  let(:amount) { 100 }
  let(:options) { [] }

  it { is_expected.to eq amount }

  context 'not matched option' do
    let(:options) { ['score_filter_9_30'] }
    it { is_expected.to eq amount }
  end

  context 'matched option' do
    let(:options) { ['score_filter_10_30'] }
    it { is_expected.to eq 70 }
  end
end
