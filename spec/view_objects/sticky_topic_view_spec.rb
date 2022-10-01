# frozen_string_literal: true

describe StickyTopicView do
  describe 'sample sticky topic' do
    let(:sticky_topic) { StickyTopicView.site_problems }
    it do
      expect(sticky_topic).to have_attributes(
        object: Topics::TopicViewFactory.new(true, true).build(site_problems_topic),
        title: site_problems_topic.title,
        description: I18n.t('sticky_topic_view.site_problems.description')
      )
    end
  end
end
