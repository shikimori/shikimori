describe BbCodes::Tags::HrTag do
  subject { described_class.instance.format text }

  context 'sample' do
    let(:text) { '[hr]' }
    it { is_expected.to eq '<hr>' }
  end

  context 'sample' do
    let(:text) { "[hr][hr]\n" }
    it { is_expected.to eq '<hr><hr>' }
  end

  context 'sample' do
    let(:text) { ['---', '___', '***'].sample + "\n" }
    it { is_expected.to eq '<hr>' }
  end

  context 'sample' do
    let(:text) { " ---\n" }
    it { is_expected.to eq text }
  end

  context 'sample' do
    let(:text) { "---z\n" }
    it { is_expected.to eq text }
  end
end
