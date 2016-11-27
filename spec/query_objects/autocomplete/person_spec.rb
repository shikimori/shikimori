describe Autocomplete::Person do
  subject(:query) do
    Autocomplete::Person.call(
      scope: scope,
      phrase: phrase
    )
  end

  describe '#call' do
    let(:scope) { Person.all }
    let(:phrase) { 'Kaichou' }

    let(:person) { build_stubbed :person }

    before do
      allow(Search::Person).to receive(:call)
        .with(phrase: phrase, scope: scope, ids_limit: Autocomplete::Person::LIMIT)
        .and_return [person]
    end

    it do
      is_expected.to eq [person]
    end
  end
end
