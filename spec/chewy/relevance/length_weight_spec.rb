describe Relevance::LengthWeight do
  subject { described_class.call length }

  context 'sample' do
    let(:length) { Relevance::LengthWeight::LENGTH_MIN }
    it { is_expected.to eq 1 }
  end

  context 'sample' do
    let(:length) { 10 }
    it { is_expected.to eq 0.988296488946684 }
  end

  context 'sample' do
    let(:length) { Relevance::LengthWeight::LENGTH_MAX }
    it { is_expected.to eq 1 / 1.025 }
  end
end
