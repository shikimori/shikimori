describe Autocomplete::Anime do
  subject(:query) do
    Autocomplete::Anime.call(
      scope: scope,
      phrase: phrase
    )
  end

  describe '#call' do
    let(:scope) { Anime.all }
    let(:phrase) { 'Kaichou' }

    let(:anime) { build_stubbed :anime }

    before do
      allow(Search::Anime).to receive(:call)
        .with(phrase: phrase, scope: scope, ids_limit: Autocomplete::Anime::LIMIT)
        .and_return [anime]
    end

    it do
      is_expected.to eq [anime]
    end
  end
end
