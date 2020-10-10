describe BbCodes::Tags::MentionTag do
  subject { described_class.instance.format text }
  let(:text) { '[mention=1345]zxc[/mention]' }

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='http://test.host/zxc' class='b-mention'
          data-id='1345' data-type='user'
          data-text='zxc'><s>@</s><span>zxc</span></a>
      HTML
    )
  end
end
