describe Autocomplete::Manga do
  subject(:query) do
    Autocomplete::Manga.call(
      scope: scope,
      phrase: phrase
    )
  end

  describe '#call' do
    let(:scope) { Manga.all }
    let(:phrase) { 'Kaichou' }

    let(:manga) { build_stubbed :manga }

    before do
      allow(Search::Manga).to receive(:call)
        .with(phrase: phrase, scope: scope, ids_limit: Autocomplete::Manga::LIMIT)
        .and_return [manga]
    end

    it do
      is_expected.to eq [manga]
    end
  end
end
