describe DbEntry::CensoredPolicy do
  subject { described_class.censored? entry }
  let(:entry) do
    build :anime,
      rating:,
      genre_v2_ids: [genre_v2.id]
  end
  let(:rating) { Types::Anime::Rating[:pg] }
  before do
    allow(AnimeGenresV2Repository)
      .to receive(:find)
      .and_return [genre_v2]
  end
  let(:genre_v2) { build_stubbed :genre_v2, id: genre_v2_id }
  let(:genre_v2_id) { 999_999 }

  it { is_expected.to eq false }

  context 'rx rating' do
    let(:rating) { Types::Anime::Rating[:rx] }
    it { is_expected.to eq true }
  end

  context 'censored genre' do
    let(:genre_v2_id) { GenreV2::HENTAI_IDS.sample }
    it { is_expected.to eq true }
  end

  context 'banned genre' do
    let(:genre_v2_id) { GenreV2::BANNED_IDS.sample }
    it { is_expected.to eq true }
  end

  context 'probably_banned genre' do
    let(:genre_v2_id) { GenreV2::AI_IDS.sample }
    it { is_expected.to eq true }
  end
end
