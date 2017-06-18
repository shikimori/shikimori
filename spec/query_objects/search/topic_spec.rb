describe Search::Topic do
  subject(:query) do
    Search::Topic.call(
      scope: scope,
      phrase: phrase,
      forum_id: forum_id,
      locale: locale,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Topic.all }
    let(:phrase) { 'Kaichou' }
    let(:forum_id) { 1 }
    let(:locale) { 'ru' }
    let(:ids_limit) { 10 }

    let!(:topic_1) { create :topic }
    let!(:topic_2) { create :topic }
    let!(:topic_3) { create :topic }

    before do
      allow(Elasticsearch::Query::Topic).to receive(:call)
        .with(
          phrase: phrase,
          forum_id: forum_id,
          locale: locale,
          limit: ids_limit
        )
        .and_return [
          { '_id' => topic_3.id },
          { '_id' => topic_1.id }
        ]
    end

    it { is_expected.to eq [topic_3, topic_1] }
  end
end
