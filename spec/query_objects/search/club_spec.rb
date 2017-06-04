describe Search::Club do
  subject(:query) do
    Search::Club.call(
      scope: scope,
      phrase: phrase,
      locale: locale,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { Club.all }
    let(:phrase) { 'Kaichou' }
    let(:locale) { 'ru' }
    let(:ids_limit) { 10 }

    let!(:club_1) { create :club }
    let!(:club_2) { create :club }
    let!(:club_3) { create :club }

    before do
      allow(Elasticsearch::Query::Club).to receive(:call)
        .with(phrase: phrase, locale: locale, limit: ids_limit)
        .and_return [
          { '_id' => club_3.id },
          { '_id' => club_1.id }
        ]
    end

    it { is_expected.to eq [club_3, club_1] }
  end
end
