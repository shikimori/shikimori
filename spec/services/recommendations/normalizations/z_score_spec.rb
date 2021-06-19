describe Recommendations::Normalizations::ZScore do
  let(:formula) { Recommendations::Normalizations::ZScore.new }
  let(:ratings) { { 4 => 4, 6 => 6, 8 => 8 } }

  it { expect(formula.sigma ratings.values, nil).to eq 2 }
  it { expect(formula.mean ratings.values, nil).to eq 6 }
  it { expect(formula.score 8, nil, ratings).to eq 1 }
  it { expect(formula.restore_score 1, nil, ratings).to eq 8 }
  it { expect(formula.restorable_sigma ratings.values).to eq 2 }
  it { expect(formula.restorable_mean ratings.values).to eq 6 }

  describe '#normalize' do
    subject { formula.normalize ratings, nil }

    # describe 'no deviation' do
    #   let(:ratings) { { 1 => 8, 2 => 8, 3 => 8 } }
    #
    #   it { expect(subject.values.first).to be_nan }
    #   it { expect(subject.values.second).to be_nan }
    #   it { expect(subject.values.third).to be_nan }
    # end

    describe 'common deviation' do
      it { is_expected.to eq 4 => -1, 6 => 0, 8 => 1 }
    end
  end
end
