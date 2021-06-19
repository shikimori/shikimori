describe Recommendations::Normalizations::MeanCentering do
  let(:formula) { Recommendations::Normalizations::MeanCentering.new }
  let(:ratings) { { 4 => 4, 6 => 6, 8 => 8 } }

  it { expect(formula.score 10, nil, ratings).to eq 4 }
  it { expect(formula.restore_score 4, nil, ratings).to eq 10 }
  it { expect(formula.restorable_mean ratings.values).to eq 6 }

  describe '#normalize' do
    subject { formula.normalize ratings, nil }

    describe 'no deviation' do
      let(:ratings) { { 1 => 8, 2 => 8, 3 => 8 } }
      it { is_expected.to eq 1 => 0, 2 => 0, 3 => 0 }
    end

    describe 'common deviation' do
      it { is_expected.to eq 4 => -2, 6 => 0, 8 => 2 }
    end
  end
end
