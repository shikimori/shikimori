describe Animes::CensoredPostersQuery do
  subject { described_class.call klass: Manga, moderation_state: }

  let(:moderation_state) { Types::Moderatable::State[:pending] }

  let!(:hentai) { create :genre_v2, :manga, id: GenreV2::TEMPORARILY_POSTERS_DISABLED_IDS.max }
  let!(:non_hentai) { create :genre_v2, :manga, id: hentai.id + 1 }

  let!(:poster_1) { create :poster, manga: manga_1 }
  let!(:poster_2) { create :poster, manga: manga_1, is_approved: false }
  let!(:poster_3) { create :poster, manga: manga_2 }
  let!(:poster_4) { create :poster, manga: manga_3 }
  let!(:poster_5) do
    create :poster, Types::Moderatable::State[:accepted],
      manga: manga_4,
      approver: user
  end

  let(:manga_1) { create :manga, score: 8, genre_v2_ids: [hentai.id, non_hentai.id] }
  let(:manga_2) { create :manga, score: 9, genre_v2_ids: [hentai.id] }
  let(:manga_3) { create :manga, genre_v2_ids: [non_hentai.id] }
  let(:manga_4) { create :manga, score: 10, genre_v2_ids: [hentai.id] }

  it { is_expected.to eq [poster_3, poster_1] }
end
