describe Search::Club do
  before do
    allow(Elasticsearch::Query::Club)
      .to receive(:call)
      .with(phrase: phrase, limit: ids_limit)
      .and_return results
  end

  subject do
    described_class.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  let(:scope) { Club.all }
  let(:phrase) { 'zxct' }
  let(:ids_limit) { 2 }

  let(:results) { { club_1.id => 0.123123 } }

  let!(:club_1) { create :club }
  let!(:club_2) { create :club }

  it { is_expected.to eq [club_1] }
end
