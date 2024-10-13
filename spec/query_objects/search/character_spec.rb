describe Search::Character do
  before do
    allow(Elasticsearch::Query::Character).to receive(:call)
      .with(phrase:, limit: ids_limit)
      .and_return(
        character_3.id => 9,
        character_1.id => 8
      )
  end

  subject { described_class.call scope:, phrase:, ids_limit: }

  let(:scope) { Character.all }
  let(:phrase) { 'Kaichou' }
  let(:ids_limit) { 10 }

  let!(:character_1) { create :character }
  let!(:character_2) { create :character }
  let!(:character_3) { create :character }

  it { is_expected.to eq [character_3, character_1] }
end
