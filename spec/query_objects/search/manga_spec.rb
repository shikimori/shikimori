describe Search::Manga do
  subject(:query) do
    Search::Manga.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Manga.all }
    let(:phrase) { 'Kaichou' }
    let(:ids_limit) { 10 }

    let!(:manga_1) { create :manga }
    let!(:manga_2) { create :manga }
    let!(:manga_3) { create :manga }

    before do
      allow(Elasticsearch::Query::Manga).to receive(:call)
        .with(phrase: phrase, limit: ids_limit)
        .and_return [
          { '_id' => manga_3.id },
          { '_id' => manga_1.id }
        ]
    end

    it do
      is_expected.to eq [manga_3, manga_1]
    end
  end
end
