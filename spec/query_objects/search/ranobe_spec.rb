describe Search::Ranobe do
  subject(:query) do
    Search::Ranobe.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Ranobe.all }
    let(:phrase) { 'Kaichou' }
    let(:ids_limit) { 10 }

    let!(:ranobe_1) { create :ranobe }
    let!(:ranobe_2) { create :ranobe }
    let!(:ranobe_3) { create :ranobe }

    before do
      allow(Elasticsearch::Query::Ranobe).to receive(:call)
        .with(phrase: phrase, limit: ids_limit)
        .and_return [
          { '_id' => ranobe_3.id },
          { '_id' => ranobe_1.id }
        ]
    end

    it do
      is_expected.to eq [ranobe_3, ranobe_1]
    end
  end
end
