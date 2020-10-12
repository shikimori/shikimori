describe BbCodes::Tags::MentionTag do
  subject { described_class.instance.format text }
  let(:text) { '[mention=1345]zxc[/mention]' }

  let(:data_attrs) do
    {
      id: 1345,
      type: :user,
      text: 'zxc'
    }
  end

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='http://test.host/zxc' class='b-mention'
          data-attrs='#{data_attrs.to_json}'><s>@</s><span>zxc</span></a>
      HTML
    )
  end
end
