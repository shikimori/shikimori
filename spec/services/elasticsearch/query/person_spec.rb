describe Elasticsearch::Query::Person do
  let(:service) do
    Elasticsearch::Query::Person.new(
      phrase: phrase,
      limit: limit,
      is_mangaka: is_mangaka,
      is_producer: is_producer,
      is_seyu: is_seyu
    )
  end
  subject { service.call }

  describe '#call', :vcr do
    let(:phrase) { 'hay' }
    let(:limit) { 10 }
    let(:is_mangaka) { false }
    let(:is_seyu) { false }
    let(:is_producer) { false }

    context 'without role' do
      it { is_expected.to have(limit).items }
    end

    context 'with role' do
      it { is_expected.to have(limit).items }
    end
  end
end
