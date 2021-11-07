describe BbCodes::CleanupCssClass do
  subject { described_class.call value }

  context 'has value' do
    let(:value) { ' test b-feedback  "zxc ' }
    it { is_expected.to eq 'test &quot;zxc' }
    it { is_expected.to be_html_safe }
  end

  context 'no value' do
    let(:value) { [nil, ''].sample }
    it { is_expected.to eq value }
  end
end
