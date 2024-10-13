describe Elasticsearch::Query::Character, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[characters]
  # include_context :chewy_logger

  subject { described_class.call phrase:, limit: ids_limit }

  let!(:character_1) { create :character, name: 'test', russian: 'аа' }
  let!(:character_2) { create :character, name: 'test zxct', russian: 'аа' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [character_1.id, character_2.id] }
end
