describe BbCodes::Tags::MentionTag do
  subject { described_class.instance.format text }
  let(:text) { "[mention=1345]#{xss}[/mention]" }
  let(:xss) { "XSS'" }

  let(:data_attrs) do
    {
      id: 1345,
      type: :user,
      text: xss
    }
  end

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='http://test.host/#{xss}' class='b-mention'
          data-attrs='#{ERB::Util.h data_attrs.to_json}'><s>@</s><span>#{ERB::Util.h xss}</span></a>
      HTML
    )
  end
end
