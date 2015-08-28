describe Versions::GenresVersion do
  let(:anime) { build_stubbed :anime }
  let(:genre_1) { create :genre }
  let(:genre_2) { create :genre }

  let(:version) { build :genres_version, item: anime, item_diff: {
    genres: [[genre_1.id, genre_2.id], [genre_2.id]] } }

  describe '#collection' do
    it { expect(version.collection).to eq [genre_2] }
    it { expect(version.collection_prior).to eq [genre_1, genre_2] }
  end

  describe '#apply_changes' do
    let(:anime) { create :anime }

    before { anime.genres = version.collection_prior }
    before { version.apply_changes }

    it { expect(anime.reload.genres).to eq [genre_2] }
  end

  describe '#rollback_changes' do
    it { expect{version.rollback_changes}.to raise_error NotImplementedError }
  end
end
