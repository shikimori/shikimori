describe Topics::SearchQuery do
  let(:query) do
    Topics::SearchQuery.new(
      scope: scope,
      phrase: phrase,
      forum: forum,
      user: user
    )
  end

  let(:scope) { Topic.where id: [topic_1.id, topic_2.id, topic_3.id] }
  let!(:topic_1) { create :topic, id: 1 }
  let!(:topic_2) { create :topic, id: 2 }
  let!(:topic_3) { create :topic, id: 3 }
  let!(:topic_4) { create :topic, id: 4 }

  describe '#search' do
    subject { query.call }

    let(:forum) { animanga_forum }
    let(:forum_id) { forum.id }
    let(:user) { nil }

    context 'with search phrase' do
      before do
        allow(Elasticsearch::Query::Topic).to receive(:call).with(
          phrase: phrase,
          forum_id: forum_id,
          limit: Topics::SearchQuery::SEARCH_LIMIT
        ).and_return(
          topic_3.id => 9,
          topic_1.id => 8,
          topic_2.id => 7
        )
      end
      let(:phrase) { 'test' }

      it 'forum is set' do
        is_expected.to eq [topic_3, topic_1, topic_2]
        expect(Elasticsearch::Query::Topic).to have_received(:call).once
      end

      context 'forum is not set' do
        let(:forum) { nil }

        context 'user is set' do
          let(:user) { seed :user }
          let(:forum_id) { user.preferences.forums.map(&:to_i) + [Forum::CLUBS_ID] }

          it do
            is_expected.to eq [topic_3, topic_1, topic_2]
            expect(Elasticsearch::Query::Topic).to have_received(:call).once
          end
        end

        context 'user is not set' do
          let(:user) { nil }
          let(:forum_id) { Forum.cached.map(&:id) }

          it do
            is_expected.to eq [topic_3, topic_1, topic_2]
            expect(Elasticsearch::Query::Topic).to have_received(:call).once
          end
        end
      end
    end

    context 'wo search phrase' do
      before { allow(Elasticsearch::Query::Topic).to receive :call }
      let(:phrase) { '' }

      it do
        is_expected.to eq scope
        expect(Elasticsearch::Query::Topic).to_not have_received :call
      end
    end
  end
end
