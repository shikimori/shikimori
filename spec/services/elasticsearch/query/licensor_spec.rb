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

  let!(:anime_1) do
    create :anime,
      id: 99999,
      name: 'anime_1',
      russian: 'аниме_1',
      licensors: ['test']
  end
  let!(:anime_2) do
    create :anime,
      id: 99998,
      name: 'anime_2',
      russian: 'аниме_2',
      licensors: ['test zxct', 'zxct']
  end
  let!(:manga_1) do
    create :manga,
      id: 99999,
      name: 'manga_1',
      russian: 'манга_1',
      licensors: ['test 2']
  end

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:kind) { Types::Licensor::Kind[:anime] }

  it { is_expected.to eq ['test', 'test zxct'] }
end
