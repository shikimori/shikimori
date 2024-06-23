describe Recommendations::Normalizations::None do
  let(:formula) { Recommendations::Normalizations::None.new }
  let(:ratings) do
    { 4 => 4, 6 => 6, 8 => 8 }
  end

  describe '#normalize' do
    subject { formula.normalize ratings, nil }
    it { is_expected.to eq ratings }
  end

  describe '#score' do
    it { expect(formula.score 10, nil, ratings).to eq 10 }
  end

  describe '#restore_score' do
    it { expect(formula.restore_score 4, nil, ratings).to eq 4 }
  end

  describe '#total_mean' do
    it { expect(formula.total_mean ratings.values, nil).to eq 0 }
  end
end
