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

  context 'non existing topic' do
    let(:text) { "[topic=#{topic_id}], test" }
    let(:topic_id) { 98765 }

    it do
      is_expected.to eq(
        "<span class='b-mention b-mention-404'><del>ID=#{topic_id}</del></span>, test"
      )
    end
  end
end
