describe BbCodes::Tags::MentionTag do
  subject { described_class.instance.format text }
  let(:text) { '[mention=1345]zxc[/mention]' }

  it do
    is_expected.to eq(
      "<a href='http://test.host/zxc' class='b-mention'><s>@</s><span>zxc</span></a>"
    )
  end
end
