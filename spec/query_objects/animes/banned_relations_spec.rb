describe Animes::BannedRelations do
  let(:query) { Animes::BannedRelations.instance }

  before { Animes::BannedRelations.instance.clear_cache! }
  after(:all) { Animes::BannedRelations.instance.clear_cache! }

  describe '#animes & #anime' do
    before do
      allow(query)
        .to receive(:cache)
        .and_return(
          animes: [[1, 2], [2, 3]]
        )
    end

    it do
      expect(query.animes).to eq(
        1 => [2],
        2 => [1, 3],
        3 => [2]
      )
      expect(query.anime 2).to eq [1, 3]
      expect(query.anime :bad_key).to eq []
    end
  end

  describe '#mangas & #manga' do
    before do
      allow(query)
        .to receive(:cache)
        .and_return(
          mangas: [[1, 2, 3, 4], [2, 5]]
        )
    end

    it do
      expect(query.mangas).to eq(
        1 => [2, 3, 4],
        2 => [1, 3, 4, 5],
        3 => [1, 2, 4],
        4 => [1, 2, 3],
        5 => [2]
      )
      expect(query.manga 5).to eq [2]
      expect(query.manga :bad_key).to eq []
    end
  end

  describe '#cache' do
    it do
      expect(query.send(:cache)).to have(2).items
      expect(query.send(:cache)[:animes]).to have_at_least(30).items
      expect(query.send(:cache)[:mangas]).to have_at_least(10).items
    end
  end
end
