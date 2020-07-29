describe BbCodes::Tags::TopicTag do
  subject { described_class.instance.format text }

  let(:text) { "[topic=#{topic.id}], test" }
  let(:topic) { create :topic, user: user, forum: animanga_forum }
  let(:topic_url) { UrlGenerator.instance.topic_url topic }

  it do
    is_expected.to eq(
      "[url=#{topic_url} bubbled]@#{user.nickname}[/url], test"
    )
  end
end
