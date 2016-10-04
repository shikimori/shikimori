describe Topics::HotTopicsQuery do
  include_context :seeds

  let(:topics) { Topics::HotTopicsQuery.call }
  let!(:club) { create :club, :with_topics }

  let!(:comment_1) { create :comment, commentable: offtopic_topic, created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago }
  let!(:comment_2) { create :comment, commentable: offtopic_topic, created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago }
  let!(:comment_3) { create :comment, commentable: site_rules_topic, created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago }
  let!(:comment_4) { create :comment, commentable: club.topics.first, created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago }

  describe '#call' do
    it { expect(topics).to eq [offtopic_topic, site_rules_topic] }
  end
end
