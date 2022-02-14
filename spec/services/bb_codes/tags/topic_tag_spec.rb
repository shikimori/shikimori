describe BbCodes::Tags::TopicTag do
  subject { described_class.instance.format text }

  let(:text) { "[topic=#{topic.id}], test" }
  let(:topic) { create topic_factory, user: user, forum: animanga_forum, linked: linked }
  let(:topic_factory) { :topic }
  let(:linked) { nil }
  let(:url) { UrlGenerator.instance.topic_url topic }

  let(:attrs) do
    {
      id: topic.id,
      type: :topic,
      userId: topic.user_id,
      text: user.nickname
    }
  end

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='#{url}' class='b-mention bubbled'
          data-attrs='#{ERB::Util.h attrs.to_json}'><s>@</s><span>#{user.nickname}</span></a>, test
      HTML
    )
  end

  describe 'review/critique tooltip_url' do
    let(:anime) { create :anime }
    let(:review) { create :review, anime: anime, user: user }
    let(:critique) { create :critique, :with_topics, user: user, target: anime }

    %i[review critique].each do |kind|
      context "#{kind} topic" do
        let(:topic_factory) { :"#{kind}_topic" }
        let(:linked) { send kind }

        it do
          is_expected.to eq(
            <<~HTML.squish
              <a href='#{url}' class='b-mention bubbled'
                data-tooltip_url='#{UrlGenerator.instance.topic_tooltip_url topic}'
                data-attrs='#{ERB::Util.h attrs.to_json}'><s>@</s><span>#{user.nickname}</span></a>, test
            HTML
          )
        end
      end
    end
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
    let(:attrs) { { id: topic_id, type: :topic } }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='#{url}' class='b-mention b-entry-404 bubbled'
            data-attrs='#{ERB::Util.h attrs.to_json}'><s>@</s><del>[topic=#{topic_id}]</del></a>, test
        HTML
      )
    end
  end
end
