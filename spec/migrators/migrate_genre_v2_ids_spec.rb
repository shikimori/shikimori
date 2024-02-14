describe MigrateGenreV2Ids do
  include_context :reset_repository, AnimeGenresRepository, true
  include_context :reset_repository, AnimeGenresV2Repository, true

  let!(:anime_1) { create :anime, genre_v2_ids: [genre_v2_action.id, genre_v2_comedy.id] }
  let!(:anime_2) { create :anime, genre_v2_ids: [genre_v2_ecchi.id, genre_v2_other.id] }
  let!(:anime_3) { create :anime, genre_v2_ids: [genre_v2_other.id, genre_v2_comedy.id] }

  let!(:genre_v1_action) { create :genre, name: 'Action', id: 3333 }
  let!(:genre_v1_comedy) { create :genre, name: 'Comedy', id: 4444 }
  let!(:genre_v1_ecchi) { create :genre, name: 'Ecchi', id: 5555 }

  let(:genre_v2_action) { create :genre_v2, name: 'Action', id: genre_v1_action.id }
  let(:genre_v2_comedy) { create :genre_v2, name: 'Comedy', id: genre_v1_ecchi.id }
  let(:genre_v2_ecchi) { create :genre_v2, name: 'Ecchi', id: genre_v1_comedy.id }
  let(:genre_v2_other) { create :genre_v2, name: 'Other', id: 9999 }

  subject! { described_class.call Anime }

  it do
    expect(GenreV2.find_by(name: 'Action').id).to eq 3333
    expect(GenreV2.find_by(name: 'Comedy').id).to eq 4444
    expect(GenreV2.find_by(name: 'Ecchi').id).to eq 5555
    expect(GenreV2.find_by(name: 'Other').id).to eq 9999

    expect(anime_1.reload.genre_v2_ids.sort).to eq [genre_v1_action.id, genre_v1_comedy.id].sort
    expect(anime_2.reload.genre_v2_ids.sort).to eq [genre_v1_ecchi.id, genre_v2_other.id].sort
    expect(anime_3.reload.genre_v2_ids.sort).to eq [genre_v2_other.id, genre_v1_comedy.id].sort
  end
end
