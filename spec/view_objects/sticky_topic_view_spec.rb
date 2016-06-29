# frozen_string_literal: true

describe StickyTopicView do
  include_context :sticky_topics

  describe 'sample sticky topic' do
    let(:sticky_topic) { StickyTopicView.faq }
    let(:faq_topic) { Topic.find StickyTopicView::TOPIC_IDS[:faq][:ru] }

    it do
      expect(sticky_topic).to have_attributes(
        url: UrlGenerator.instance.topic_url(faq_topic),
        title: I18n.t('topics/sticky_topic.faq.title'),
        description: I18n.t('topics/sticky_topic.faq.description')
      )
    end
  end
end
