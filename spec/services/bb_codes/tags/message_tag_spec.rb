describe BbCodes::Tags::MessageTag do
  subject { described_class.instance.format text }

  let(:text) { "[message=#{message.id}], test" }
  let(:url) { UrlGenerator.instance.profile_url user }
  let(:message) { create :message, from: user }

  it do
    is_expected.to eq(
      "[url=#{url} bubbled b-mention]#{user.nickname}[/url], test"
    )
  end
end
