describe BbCodes::Tags::BroadcastTag do
  let(:tag) { BbCodes::Tags::BroadcastTag.instance }

  describe '#format' do
    subject { tag.format text }

    context '\n' do
      let(:text) { 'z[broadcast]x' }
      it { is_expected.to eq 'zx' }
    end

    context 'no text' do
      let(:text) { '[broadcast]' }
      it { is_expected.to eq '' }
    end
  end
end
