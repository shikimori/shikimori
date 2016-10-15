describe BbCodes::BroadcastTag do
  let(:tag) { BbCodes::BroadcastTag.instance }

  describe '#format' do
    subject { tag.format text }

    context '\n' do
      let(:text) { "z\n[broadcast]x" }
      it { is_expected.to eq "z\nx" }
    end

    context '<br>' do
      let(:text) { "z<br>[broadcast]x" }
      it { is_expected.to eq "z<br>x" }
    end

    context 'no new lines' do
      let(:text) { '[broadcast]' }
      it { is_expected.to eq '' }
    end
  end
end
