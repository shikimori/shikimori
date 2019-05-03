describe BbCodes::Tags::PollTag do
  let(:tag) { BbCodes::Tags::PollTag.instance }

  describe '#format' do
    let(:text) { '[poll=13]' }
    subject { tag.format text }
    it do
      is_expected.to eq '<div class="poll-placeholder" '\
        'id="13" data-track_poll="13"></div>'
    end
  end
end
