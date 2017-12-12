describe Elasticsearch::Query::Collection, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :collections
    CollectionsIndex.purge!
  end

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit,
      locale: 'ru'
    )
  end

  let!(:collection_1) { create :collection, name: 'test', locale: 'ru' }
  let!(:collection_2) { create :collection, name: 'test zxct', locale: 'ru' }
  let!(:collection_3) { create :collection, name: 'test 2', locale: 'en' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [collection_1.id, collection_2.id] }
end
