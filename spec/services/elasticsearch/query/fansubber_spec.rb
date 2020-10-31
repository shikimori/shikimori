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

  let!(:anime_1) { create :anime, fansubbers: ['test'] }
  let!(:anime_2) { create :anime, fansubbers: ['test zxct', 'zxct'] }
  let!(:anime_3) { create :anime, fandubbers: ['test 2'] }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:kind) { Types::Fansubber::Kind[:fansubber] }

  it { is_expected.to eq ['test', 'test zxct'] }
end
