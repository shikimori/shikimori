describe MigrateGenreV2Ids do
  [
    AnimeGenresRepository,
    MangaGenresRepository,
    AnimeGenresV2Repository,
    MangaGenresV2Repository
  ].each do |klass|
    include_context :reset_repository, klass, true
  end

  let!(:anime_1) do
    create :anime, genre_v2_ids: [genre_v2_anime_action.id, genre_v2_anime_comedy.id]
  end
  let!(:anime_2) do
    create :anime, genre_v2_ids: [genre_v2_anime_ecchi.id, genre_v2_anime_other.id]
  end
  let!(:anime_3) do
    create :anime, genre_v2_ids: [genre_v2_anime_other.id, genre_v2_anime_comedy.id]
  end

  let!(:manga_1) do
    create :manga, genre_v2_ids: [genre_v2_manga_other.id, genre_v2_manga_school.id]
  end

  let!(:genre_v1_anime_action) { create :genre, :anime, name: 'Action', id: 3333 }
  let!(:genre_v1_anime_comedy) { create :genre, :anime, name: 'Comedy', id: 4444 }
  let!(:genre_v1_anime_ecchi) { create :genre, :anime, name: 'Ecchi', id: 5555 }
  let!(:genre_v1_anime_school) { create :genre, :anime, name: 'School', id: 6666 }

  let!(:genre_v2_anime_action) { create :genre_v2, :anime, name: 'Action', id: 3333 }
  let!(:genre_v2_anime_comedy) { create :genre_v2, :anime, name: 'Comedy', id: 5555 }
  let!(:genre_v2_anime_ecchi) { create :genre_v2, :anime, name: 'Ecchi', id: 4444 }
  let!(:genre_v2_anime_school) { create :genre_v2, :anime, name: 'School', id: 8888 }
  let!(:genre_v2_anime_other) { create :genre_v2, :anime, name: 'Other', id: 9999 }

  let!(:genre_v2_manga_school) { create :genre_v2, :manga, name: 'School', id: 6666 }
  let!(:genre_v2_manga_other) { create :genre_v2, :manga, name: 'Other', id: 9998 }

  let!(:version_genre_v2_anime_action) do
    create :version, item: genre_v2_anime_action, item_diff: { 'name' => ['a', 'b'] }
  end
  let!(:version_genre_v2_anime_comedy) do
    create :version, item: genre_v2_anime_comedy, item_diff: { 'name' => ['a', 'b'] }
  end

  subject! { described_class.call Anime }

  it do
    expect(GenreV2.find_by(name: 'Action', entry_type: 'Anime').id).to eq 3333
    expect(GenreV2.find_by(name: 'Comedy', entry_type: 'Anime').id).to eq 4444
    expect(GenreV2.find_by(name: 'Ecchi', entry_type: 'Anime').id).to eq 5555
    expect(GenreV2.find_by(name: 'School', entry_type: 'Anime').id).to eq 6666
    expect(GenreV2.find_by(name: 'School', entry_type: 'Manga').id).to eq 8888
    expect(GenreV2.find_by(name: 'Other', entry_type: 'Anime').id).to eq 9999

    expect(anime_1.reload.genre_v2_ids).to eq [3333, 4444]
    expect(anime_2.reload.genre_v2_ids).to eq [9999, 5555]
    expect(anime_3.reload.genre_v2_ids).to eq [9999, 4444]

    expect(manga_1.reload.genre_v2_ids).to eq [9998, 8888]

    expect(version_genre_v2_anime_action.reload.item_id).to eq 3333
    expect(version_genre_v2_anime_comedy.reload.item_id).to eq 4444
  end
end
