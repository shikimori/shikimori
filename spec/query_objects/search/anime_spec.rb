describe Search::Anime do
  subject(:query) do
    Search::Anime.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Anime.all }
    let(:phrase) { 'Kaichou' }
    let(:ids_limit) { 10 }

    let!(:anime_1) { create :anime }
    let!(:anime_2) { create :anime }
    let!(:anime_3) { create :anime }

    before do
      allow(Elasticsearch::Query::Anime).to receive(:call)
        .with(phrase: phrase, limit: ids_limit)
        .and_return [
          { '_id' => anime_3.id },
          { '_id' => anime_1.id }
        ]
    end

    it do
      is_expected.to eq [anime_3, anime_1]
    end
  end
end
