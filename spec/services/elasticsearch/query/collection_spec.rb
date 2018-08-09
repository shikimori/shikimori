describe Elasticsearch::Query::Collection, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[collections]
  # include_context :chewy_logger

  subject { described_class.call phrase: phrase, limit: ids_limit, locale: locale }

  let!(:collection_1) { create :collection, name: 'test', locale: 'ru' }
  let!(:collection_2) { create :collection, name: 'test zxct', locale: 'ru' }
  let!(:collection_3) { create :collection, name: 'test 2', locale: 'en' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:locale) { 'ru' }

  it { is_expected.to have_keys [collection_1.id, collection_2.id] }
end
