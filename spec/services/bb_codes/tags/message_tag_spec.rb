describe BbCodes::Tags::MessageTag do
  subject { described_class.instance.format text }

  let(:text) { "[message=#{message.id}], test" }
  let(:url) { UrlGenerator.instance.message_url message }
  let(:message) { create :message, from: user }

  let(:data_attrs) do
    {
      id: message.id,
      type: :message,
      user_id: message.from_id,
      text: user.nickname
    }
  end

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='#{url}' class='b-mention bubbled'
          data-attrs='#{data_attrs.to_json}'><s>@</s><span>#{user.nickname}</span></a>, test
      HTML
    )
  end

  context 'non existing message' do
    let(:message) { build_stubbed :message }

    let(:data_attrs) do
      {
        id: message.id,
        type: :message,
        user_id: nil,
        text: nil
      }
    end

    it do
      is_expected.to eq(
        <<~HTML.squish
          <span class='b-mention b-entry-404'
            data-attrs='#{data_attrs.to_json}'><s>@</s><del>[message=#{message.id}]</del></span>, test
        HTML
      )
    end
  end
end
