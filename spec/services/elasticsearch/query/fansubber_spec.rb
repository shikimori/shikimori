describe Elasticsearch::Query::Fansubber, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[fansubbers]
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
      fansubbers: ['test']
  end
  let!(:anime_2) do
    create :anime,
      id: 99998,
      name: 'anime_2',
      russian: 'аниме_2',
      fansubbers: ['test zxct', 'zxct']
  end
  let!(:anime_3) do
    create :anime,
      id: 99997,
      name: 'anime_3',
      russian: 'аниме_3',
      fandubbers: ['test 2']
  end

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:kind) { Types::Fansubber::Kind[:fansubber] }

  it { is_expected.to eq ['test', 'test zxct'] }
end
