describe Autocomplete::Person do
  subject(:query) do
    Autocomplete::Person.call(
      scope: scope,
      phrase: phrase,
      is_mangaka: is_mangaka,
      is_seyu: is_seyu,
      is_producer: is_producer
    )
  end

  describe '#call' do
    let(:scope) { Person.all }
    let(:phrase) { 'Kaichou' }
    let(:is_mangaka) { false }
    let(:is_producer) { true }
    let(:is_seyu) { false }

    let(:person) { build_stubbed :person }

    before do
      allow(Search::Person).to receive(:call)
        .with(
          phrase: phrase,
          scope: scope,
          ids_limit: Autocomplete::Person::LIMIT,
          is_mangaka: is_mangaka,
          is_producer: is_producer,
          is_seyu: is_seyu
        )
        .and_return [person]
    end

    it do
      is_expected.to eq [person]
    end
  end
end
