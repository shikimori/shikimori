describe Animes::AutocompleteQuery do
  subject(:query) do
    Animes::AutocompleteQuery.call(
      scope: scope,
      phrase: phrase
    )
  end

  describe '#call' do
    let(:scope) { Anime.all }
    let(:phrase) { 'Kaichou' }

    let(:anime_1) { build_stubbed :anime }

    before do
      allow(Animes::SearchQuery).to receive(:call)
        .with(phrase: phrase, scope: scope, ids_limit: Animes::AutocompleteQuery::LIMIT)
        .and_return [anime_1]
    end

    it do
      is_expected.to eq [anime_1]
    end
  end
end
