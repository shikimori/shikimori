describe Autocomplete::Character do
  subject(:query) do
    Autocomplete::Character.call(
      scope: scope,
      phrase: phrase
    )
  end

  describe '#call' do
    let(:scope) { Character.all }
    let(:phrase) { 'Kaichou' }

    let(:character) { build_stubbed :character }

    before do
      allow(Search::Character).to receive(:call)
        .with(phrase: phrase, scope: scope, ids_limit: Autocomplete::Character::LIMIT)
        .and_return [character]
    end

    it do
      is_expected.to eq [character]
    end
  end
end
