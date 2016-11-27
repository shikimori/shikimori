describe Search::Person do
  subject(:query) do
    Search::Person.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Person.all }
    let(:phrase) { 'Kaichou' }
    let(:ids_limit) { 10 }

    let!(:person_1) { create :person }
    let!(:person_2) { create :person }
    let!(:person_3) { create :person }

    before do
      allow(Elasticsearch::Search::Person).to receive(:call)
        .with(phrase: phrase, limit: ids_limit)
        .and_return [
          { '_id' => person_3.id },
          { '_id' => person_1.id }
        ]
    end

    it do
      is_expected.to eq [person_3, person_1]
    end
  end
end
