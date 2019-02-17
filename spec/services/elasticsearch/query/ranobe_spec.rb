describe Elasticsearch::Query::Ranobe, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[ranobe]
  # include_context :chewy_logger

  subject { described_class.call phrase: phrase, limit: ids_limit }

  let!(:ranobe_1) { create :ranobe, name: 'test', russian: 'аа' }
  let!(:ranobe_2) { create :ranobe, name: 'test zxct', russian: 'аа' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [ranobe_1.id, ranobe_2.id] }
end
