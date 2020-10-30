describe Search::Licensor do
  before do
    allow(Elasticsearch::Query::Licensor)
      .to receive(:call)
      .with(phrase: phrase, limit: ids_limit, kind: kind)
      .and_return results
  end

  subject do
    described_class.call(
      phrase: phrase,
      ids_limit: ids_limit,
      kind: kind
    )
  end

  let(:phrase) { 'zxct' }
  let(:ids_limit) { 2 }
  let(:kind) { 'anime' }

  let(:results) { ['zxc'] }

  it { is_expected.to eq results }
end
