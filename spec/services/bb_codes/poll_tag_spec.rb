describe BbCodes::PollTag do
  let(:tag) { BbCodes::PollTag.instance }

  describe '#format' do
    let(:text) { '[poll=13]' }
    subject { tag.format text }
    it { is_expected.to eq '<div data-track_poll="13"></div>' }
  end
end
