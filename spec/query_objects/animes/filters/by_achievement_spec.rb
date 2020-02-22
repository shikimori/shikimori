describe Animes::Filters::ByAchievement do
  subject { described_class.call scope, terms }

  let(:scope) { Anime.order :id }
  let(:terms) { 'otaku' }

  let(:hentai) { create :genre, id: Genre::HENTAI_IDS.first }

  let!(:anime_1) { create :anime, genre_ids: [hentai.id] }
  let!(:anime_2) { create :anime, genre_ids: [hentai.id] }
  let!(:anime_3) { create :anime }

  it { is_expected.to eq [anime_1, anime_2] }

  context 'invalid parameter' do
    let(:terms) { 'zzz' }
    it { expect { subject }.to raise_error InvalidParameterError }
  end

  context 'invalid scope' do
    let(:scope) { [Manga.all, Ranobe.all].sample }
    it { expect { subject }.to raise_error InvalidParameterError }
  end
end
