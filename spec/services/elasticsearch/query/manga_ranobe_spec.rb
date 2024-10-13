describe Elasticsearch::Query::MangaRanobe, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[manga_ranobe]
  # include_context :chewy_logger

  subject { described_class.call phrase:, limit: ids_limit }

  let!(:manga_1) { create :manga, name: 'test', russian: 'аа' }
  let!(:manga_2) { create :ranobe, name: 'test zxct', russian: 'аа' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [manga_1.id, manga_2.id] }
end
