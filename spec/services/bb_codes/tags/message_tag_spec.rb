describe BbCodes::Tags::MessageTag do
  subject { described_class.instance.format text }

  let(:text) { "[message=#{message.id}], test" }
  let(:url) { UrlGenerator.instance.message_url message }
  let(:message) { create :message, from: user }

  let(:attrs) do
    {
      id: message.id,
      type: :message,
      userId: message.from_id,
      text: user.nickname
    }
  end

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='#{url}' class='b-mention bubbled'
          data-attrs='#{attrs.to_json}'><s>@</s><span>#{user.nickname}</span></a>, test
      HTML
    )
  end

  context 'non existing message' do
    let(:message) { build_stubbed :message }
    let(:attrs) { { id: message.id, type: :message } }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='#{url}' class='b-mention b-entry-404 bubbled'
            data-attrs='#{attrs.to_json}'><s>@</s><del>[message=#{message.id}]</del></a>, test
        HTML
      )
    end
  end
end
