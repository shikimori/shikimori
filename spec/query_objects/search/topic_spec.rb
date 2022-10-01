describe Search::Topic do
  before do
    allow(Elasticsearch::Query::Topic)
      .to receive(:call)
      .with(phrase: phrase, limit: ids_limit, forum_id: forum_id)
      .and_return results
  end

  subject do
    described_class.call(
      scope: scope,
      phrase: phrase,
      forum_id: forum_id,
      ids_limit: ids_limit
    )
  end

  let(:scope) { Topic.all }
  let(:phrase) { 'zxct' }
  let(:ids_limit) { 2 }
  let(:forum_id) { Topic::FORUM_IDS[Anime.name] }

  let(:results) { { topic_1.id => 0.123123 } }

  let!(:topic_1) { create :topic }
  let!(:topic_2) { create :topic }

  it { is_expected.to eq [topic_1] }
end
