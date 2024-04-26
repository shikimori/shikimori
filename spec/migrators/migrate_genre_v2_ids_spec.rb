describe MigrateGenreV2Ids do
  # [
  #   AnimeGenresRepository,
  #   MangaGenresRepository,
  #   AnimeGenresV2Repository,
  #   MangaGenresV2Repository
  # ].each do |klass|
  #   include_context :reset_repository, klass
  # end
  subject { described_class.call Anime }

  describe 'common rules' do
    let!(:anime_1) do
      create :anime, genre_v2_ids: [genre_v2_anime_action.id, genre_v2_anime_comedy.id]
    end
    let!(:anime_2) do
      create :anime, genre_v2_ids: [genre_v2_anime_ecchi.id, genre_v2_anime_other.id]
    end
    let!(:anime_3) do
      create :anime, genre_v2_ids: [genre_v2_anime_other.id, genre_v2_anime_comedy.id]
    end

    let!(:genre_v1_anime_action) { create :genre, :anime, name: 'Action', id: 1 }
    let!(:genre_v1_anime_comedy) { create :genre, :anime, name: 'Comedy', id: 2 }
    let!(:genre_v1_anime_ecchi) { create :genre, :anime, name: 'Ecchi', id: 3 }

    let!(:genre_v2_anime_action) { create :genre_v2, :anime, name: 'Action', id: 1 }
    let!(:genre_v2_anime_comedy) { create :genre_v2, :anime, name: 'Comedy', id: 3 }
    let!(:genre_v2_anime_ecchi) { create :genre_v2, :anime, name: 'Ecchi', id: 2 }
    let!(:genre_v2_anime_other) { create :genre_v2, :anime, name: 'Other', id: 6 }

    let!(:version_genre_v2_anime_action) do
      create :version, item: genre_v2_anime_action, item_diff: { 'name' => ['a', 'b'] }
    end
    let!(:version_genre_v2_anime_comedy) do
      create :version, item: genre_v2_anime_comedy, item_diff: { 'name' => ['a', 'b'] }
    end

    it do
      is_expected.to eq true
      expect(GenreV2.find_by(name: 'Action', entry_type: 'Anime').id).to eq 1
      expect(GenreV2.find_by(name: 'Comedy', entry_type: 'Anime').id).to eq 2
      expect(GenreV2.find_by(name: 'Ecchi', entry_type: 'Anime').id).to eq 3
      expect(GenreV2.find_by(name: 'Other', entry_type: 'Anime').id).to eq 6

      expect(anime_1.reload.genre_v2_ids).to eq [1, 2]
      expect(anime_2.reload.genre_v2_ids).to eq [6, 3]
      expect(anime_3.reload.genre_v2_ids).to eq [6, 2]

      expect(version_genre_v2_anime_action.reload.item_id).to eq 1
      expect(version_genre_v2_anime_comedy.reload.item_id).to eq 2
    end
  end

  context 'conflicts with manga genre ids' do
    let!(:manga_1) do
      create :manga, genre_v2_ids: [genre_v2_manga_other.id, genre_v2_manga_school.id]
    end

    let!(:genre_v1_anime_school) { create :genre, :anime, name: 'School', id: 4 }
    let!(:genre_v2_anime_school) { create :genre_v2, :anime, name: 'School', id: 5 }
    let!(:genre_v2_manga_school) { create :genre_v2, :manga, name: 'School', id: 4 }
    let!(:genre_v2_manga_other) { create :genre_v2, :manga, name: 'Other', id: 7 }

    it do
      is_expected.to eq true
      expect(GenreV2.find_by(name: 'School', entry_type: 'Anime').id).to eq 4
      expect(GenreV2.find_by(name: 'School', entry_type: 'Manga').id).to eq 5
      expect(manga_1.reload.genre_v2_ids).to eq [7, 5]
    end
  end

  context 'ignores genre_v1 of other kind' do
    let!(:genre_v1_manga_school) { create :genre, :manga, name: 'School', id: 1 }
    let!(:genre_v1_anime_school) { create :genre, :anime, name: 'School', id: 2 }

    let!(:genre_v2_anime_school) { create :genre_v2, :anime, name: 'School', id: 3 }
    it do
      is_expected.to eq true
      expect(GenreV2.find_by(name: 'School', entry_type: 'Anime').id).to eq 2
    end
  end

  context 'special migration rules' do
    context 'unaffected genres having matched russian name are not changed' do
      let!(:genre_v1_anime_cars) { create :genre, :anime, name: 'Cars', russian: 'Машины', id: 1 }
      let!(:genre_v2_anime_cars) { create :genre_v2, :anime, name: 'Cars', id: 2 }

      it do
        is_expected.to eq true
        expect(GenreV2.find_by(name: 'Cars', entry_type: 'Anime').id).to eq 2
      end
    end

    context 'genre ids swap' do
      let!(:genre_v1_anime_cars) { create :genre, :anime, name: 'Cars', russian: 'Машины', id: 1 }
      let!(:genre_v2_anime_cars) { create :genre_v2, :anime, name: 'Cars', id: 2 }
      let!(:genre_v2_anime_racing) { create :genre_v2, :anime, name: 'Racing', russian: 'Гонки', id: 3 }

      it do
        is_expected.to eq true
        expect(GenreV2.find_by(name: 'Cars', entry_type: 'Anime').id).to eq 2
        expect(GenreV2.find_by(name: 'Racing', entry_type: 'Anime').id).to eq 1
      end
    end
  end
end
