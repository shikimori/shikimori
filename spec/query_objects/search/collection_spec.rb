describe Search::Collection do
  subject(:query) do
    Search::Collection.call(
      scope: scope,
      phrase: phrase,
      locale: locale,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Collection.all }
    let(:phrase) { 'Kaichou' }
    let(:locale) { 'ru' }
    let(:ids_limit) { 10 }

    let!(:collection_1) { create :collection }
    let!(:collection_2) { create :collection }
    let!(:collection_3) { create :collection }

    before do
      allow(Elasticsearch::Query::Collection).to receive(:call)
        .with(phrase: phrase, locale: locale, limit: ids_limit)
        .and_return [
          { '_id' => collection_3.id },
          { '_id' => collection_1.id }
        ]
    end

    it { is_expected.to eq [collection_3, collection_1] }
  end
end
