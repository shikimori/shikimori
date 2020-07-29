describe BbCodes::Tags::PollTag do
  subject { described_class.instance.format text }
  let(:text) { '[poll=13]' }
  it do
    is_expected.to eq '<div class="poll-placeholder" '\
      'id="13" data-track_poll="13"></div>'
  end
end
