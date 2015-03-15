describe BannedRelations do
  let(:query) { BannedRelations.instance }

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
end
