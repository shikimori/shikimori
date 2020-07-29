describe BbCodes::Tags::TopicTag do
  subject { described_class.instance.format text }

  let(:text) { "[topic=#{topic.id}], test" }
  let(:topic) { create :topic, user: user, forum: animanga_forum }
  let(:url) { UrlGenerator.instance.topic_url topic }

  it do
    is_expected.to eq(
      "[url=#{url} bubbled b-mention]#{user.nickname}[/url], test"
    )
  end
end
