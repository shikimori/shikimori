describe Recommendations::Normalizations::ConstCut do
  let(:formula) { Recommendations::Normalizations::ConstCut.new }
  let(:ratings) { { 4 => 4, 6 => 6, 8 => 8 } }

  describe '#normalize' do
    it { expect(formula.normalize ratings, nil).to eq 4 => 5, 6 => 6, 8 => 8 }
  end
end
