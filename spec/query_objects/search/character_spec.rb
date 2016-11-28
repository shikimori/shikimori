describe Search::Character do
  subject(:query) do
    Search::Character.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Character.all }
    let(:phrase) { 'Kaichou' }
    let(:ids_limit) { 10 }

    let!(:character_1) { create :character }
    let!(:character_2) { create :character }
    let!(:character_3) { create :character }

    before do
      allow(Elasticsearch::Query::Character).to receive(:call)
        .with(phrase: phrase, limit: ids_limit)
        .and_return [
          { '_id' => character_3.id },
          { '_id' => character_1.id }
        ]
    end

    it do
      is_expected.to eq [character_3, character_1]
    end
  end
end
