describe BbCodes::PollTag do
  let(:tag) { BbCodes::PollTag.instance }

  describe '#format' do
    let(:text) { '[poll=13]' }
    subject { tag.format text }
    it do
      is_expected.to eq '<div class="poll-placeholder not-tracked" '\
        'id="13" data-track_poll="13"></div>'
    end
  end
end
