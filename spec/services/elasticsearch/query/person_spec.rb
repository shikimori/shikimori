describe Elasticsearch::Query::Person, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :people
    PeopleIndex.purge!
  end

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit,
      is_mangaka: is_mangaka,
      is_seyu: is_seyu,
      is_producer: is_producer
    )
  end

  let!(:person_1) do
    create :person,
      name: 'test',
      mangaka: is_mangaka,
      seyu: is_seyu,
      producer: is_producer
  end
  let!(:person_2) { create :person, name: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:is_mangaka) { false }
  let(:is_seyu) { false }
  let(:is_producer) { false }

  it { is_expected.to have_keys [person_1.id, person_2.id] }

  context 'mangaka' do
    let(:is_mangaka) { true }
    it { is_expected.to have_keys [person_1.id] }
  end

  context 'seyu' do
    let(:is_seyu) { true }
    it { is_expected.to have_keys [person_1.id] }
  end

  context 'producer' do
    let(:is_producer) { true }
    it { is_expected.to have_keys [person_1.id] }
  end
end
