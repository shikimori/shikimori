describe BbCodes::Tags::TopicTag do
  subject { described_class.instance.format text }

  let(:text) { "[topic=#{topic.id}], test" }
  let(:topic) { create :topic, user: user, forum: animanga_forum }
  let(:url) { UrlGenerator.instance.topic_url topic }

  let(:data_attrs) do
    {
      id: topic.id,
      type: :topic,
      user_id: topic.user_id,
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

  context 'non existing topic' do
    let(:text) { "[topic=#{topic_id}], test" }
    let(:topic_id) { 98765 }
    let(:url) do
      UrlGenerator.instance.forum_topic_url(
        id: topic_id,
        forum: offtopic_forum
      )
    end
    let(:data_attrs) { { id: topic_id, type: :topic } }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='#{url}' class='b-mention b-entry-404 bubbled'
            data-attrs='#{data_attrs.to_json}'><s>@</s><del>[topic=#{topic_id}]</del></a>, test
        HTML
      )
    end
  end
end
