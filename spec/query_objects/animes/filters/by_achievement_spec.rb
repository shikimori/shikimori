describe Animes::Filters::ByAchievement do
  subject { described_class.call Anime.order(:id), terms }

  let(:terms) { 'otaku' }

  let(:hentai) { create :genre, id: Genre::HENTAI_IDS.first }

  let!(:anime_1) { create :anime, genre_ids: [hentai.id] }
  let!(:anime_2) { create :anime, genre_ids: [hentai.id] }
  let!(:anime_3) { create :anime }

  it { is_expected.to eq [anime_1, anime_2] }
end
