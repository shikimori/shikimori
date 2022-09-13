describe Search::Collection do
  before do
    allow(Elasticsearch::Query::Collection)
      .to receive(:call)
      .with(phrase: phrase, limit: ids_limit)
      .and_return results
  end
  subject do
    described_class.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Collection.all }
    let(:phrase) { 'zxct' }
    let(:ids_limit) { 2 }

    let(:results) { { collection_1.id => 0.123123 } }

    let!(:collection_1) { create :collection }
    let!(:collection_2) { create :collection }

    it { is_expected.to eq [collection_1] }
  end
end
