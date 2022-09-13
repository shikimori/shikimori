describe Topics::HotTopicsQuery do
  subject { Topics::HotTopicsQuery.call limit: 8 }

  describe '#call' do
    describe 'order by comments count' do
      let!(:comment_1) do
        create :comment,
          commentable: site_problems_topic,
          created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago
      end
      let!(:comment_2) do
        create :comment,
          commentable: site_problems_topic,
          created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago
      end
      let!(:comment_3) do
        create :comment,
          commentable: site_rules_topic,
          created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago
      end

      it { is_expected.to eq [site_problems_topic, site_rules_topic] }
    end

    describe 'filter by topic locale' do
      let!(:en_topic) { create :topic }

      let!(:comment_1) do
        create :comment,
          commentable: en_topic,
          created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago
      end

      it { is_expected.to be_empty }
    end

    describe 'except offtopic & club topics' do
      let!(:club) { create :club, :with_topics }

      let!(:comment_1) do
        create :comment,
          commentable: club.topic,
          created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago
      end
      let!(:comment_2) do
        create :comment,
          commentable: offtopic_topic,
          created_at: (Topics::HotTopicsQuery::INTERVAL - 1.minute).ago
      end

      it { is_expected.to be_empty }
    end
  end
end
