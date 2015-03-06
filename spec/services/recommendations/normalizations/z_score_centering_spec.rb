describe Recommendations::Normalizations::ZScoreCentering do
  let(:formula) { Recommendations::Normalizations::ZScoreCentering.new }

  describe '#sigma' do
    it { expect(formula.sigma [4,6,8], nil).to eq 1.632993161855452 }
  end
end
