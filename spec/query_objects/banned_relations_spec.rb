describe BannedRelations do
  let(:query) { BannedRelations.instance }
  after { BannedRelations.instance.clear_cache! }

  describe '#animes & #anime' do
    before { allow(query).to receive(:cache).and_return animes: [[1,2],[2,3]] }
    it { expect(query.animes).to eq 1 => [2], 2 => [1,3], 3 => [2] }
    it { expect(query.anime 2).to eq [1,3] }
    it { expect(query.anime :bad_key).to eq [] }
  end

  describe '#mangas & #manga' do
    before { allow(query).to receive(:cache).and_return mangas: [[1,2,3,4],[2,5]] }
    it { expect(query.mangas).to eq 1 => [2,3,4], 2 => [1,3,4,5], 3 => [1,2,4], 4 => [1,2,3], 5 => [2] }
    it { expect(query.manga 5).to eq [2] }
    it { expect(query.manga :bad_key).to eq [] }
  end

  describe '#cache' do
    it { expect(query.send(:cache)).to have(2).items }
    it { expect(query.send(:cache)[:animes]).to have_at_least(30).items }
    it { expect(query.send(:cache)[:mangas]).to have_at_least(10).items }
  end
end
