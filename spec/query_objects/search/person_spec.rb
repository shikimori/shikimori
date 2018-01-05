describe Search::Person do
  before do
    allow(Elasticsearch::Query::Person).to receive(:call)
      .with(
        phrase: phrase,
        limit: ids_limit,
        is_mangaka: is_mangaka,
        is_producer: is_producer,
        is_seyu: is_seyu
      )
      .and_return(
        person_3.id => 9,
        person_1.id => 8
      )
  end

  subject do
    described_class.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit,
      is_mangaka: is_mangaka,
      is_seyu: is_seyu,
      is_producer: is_producer
    )
  end

  let(:scope) { Person.all }
  let(:phrase) { 'Kaichou' }
  let(:ids_limit) { 10 }
  let(:is_mangaka) { false }
  let(:is_producer) { true }
  let(:is_seyu) { false }

  let!(:person_1) { create :person }
  let!(:person_2) { create :person }
  let!(:person_3) { create :person }

  it { is_expected.to eq [person_3, person_1] }
end
