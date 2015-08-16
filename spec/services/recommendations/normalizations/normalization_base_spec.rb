describe Recommendations::Normalizations::NormalizationBase do
  let(:formula) { Recommendations::Normalizations::NormalizationBase.new }
  let(:scores) { [5, 6, 6, 7, 7, 7, 8, 8, 9] }

  it { expect(formula.mean scores, nil).to eq 7 }
  it { expect(formula.sigma scores, nil).to eq 1.224744871391589 }
  #it { expect{formula.score nil, nil, nil}.to raise_error NotImplementedError }
  #it { expect{formula.restore_score nil, nil, nil}.to raise_error NotImplementedError }
  it { expect(formula.restorable_mean nil).to eq 0 }
  it { expect(formula.restorable_sigma nil).to eq 1 }
end
