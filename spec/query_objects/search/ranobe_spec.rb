describe Search::Ranobe do
  before do
    allow(Elasticsearch::Query::Ranobe).to receive(:call)
      .with(phrase:, limit: ids_limit)
      .and_return(
        ranobe_3.id => 9,
        ranobe_1.id => 8
      )
  end

  subject { described_class.call scope:, phrase:, ids_limit: }

  let(:scope) { Ranobe.all }
  let(:phrase) { 'Kaichou' }
  let(:ids_limit) { 10 }

  let!(:ranobe_1) { create :ranobe }
  let!(:ranobe_2) { create :ranobe }
  let!(:ranobe_3) { create :ranobe }

  it { is_expected.to eq [ranobe_3, ranobe_1] }
end
