describe Elasticsearch::Query::Licensor, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[licensors]
  # include_context :chewy_logger

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit,
      kind: kind
    )
  end

  let!(:anime_1) { create :anime, licensors: ['test'] }
  let!(:anime_2) { create :anime, licensors: ['test zxct', 'zxct'] }
  let!(:manga_1) { create :manga, licensors: ['test 2'] }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:kind) { Types::Licensor::Kind[:anime] }

  it { is_expected.to eq ['test', 'test zxct'] }
end
