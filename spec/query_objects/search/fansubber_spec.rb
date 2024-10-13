describe Search::Fansubber do
  before do
    allow(Elasticsearch::Query::Fansubber)
      .to receive(:call)
      .with(phrase:, limit: ids_limit, kind:)
      .and_return results
  end

  subject { described_class.call phrase:, ids_limit:, kind: }

  let(:phrase) { 'zxct' }
  let(:ids_limit) { 2 }
  let(:kind) { 'anime' }

  let(:results) { ['zxc'] }

  it { is_expected.to eq results }
end
