describe BbCodes::Tags::BroadcastTag do
  subject { described_class.instance.format text }

  context '\n' do
    let(:text) { 'z[broadcast]x' }
    it { is_expected.to eq 'zx' }
  end

  context 'no text' do
    let(:text) { '[broadcast]' }
    it { is_expected.to eq '' }
  end
end
