describe BbCodes::Tags::MessageTag do
  subject { described_class.instance.format text }

  let(:text) { "[message=#{message.id}], test" }
  let(:url) { UrlGenerator.instance.message_url message }
  let(:message) { create :message, from: user }

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='#{url}' class='b-mention bubbled'
          data-id='#{message.id}' data-type='message'
          data-text='#{user.nickname}'><s>@</s><span>#{user.nickname}</span></a>, test
      HTML
    )
  end

  context 'non existing message' do
    let(:message) { build_stubbed :message }

    it do
      is_expected.to eq(
        "<span class='b-mention b-entry-404'><s>@</s>" \
          "<del>[message=#{message.id}]</del></span>, test"
      )
    end
  end
end
