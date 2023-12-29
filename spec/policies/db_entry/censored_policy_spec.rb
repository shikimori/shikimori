describe DbEntry::CensoredPolicy do
  subject { described_class.censored? entry }
  let(:entry) do
    build :anime,
      rating:,
      genre_ids: [genre.id]
  end
  let(:rating) { Types::Anime::Rating[:pg] }
  before do
    allow(AnimeGenresRepository)
      .to receive(:find)
      .and_return [genre]
  end
  let(:genre) { build_stubbed :genre, id: genre_id }
  let(:genre_id) { 999_999 }

  it { is_expected.to eq false }

  context 'rx rating' do
    let(:rating) { Types::Anime::Rating[:rx] }
    it { is_expected.to eq true }
  end

  context 'censored genre' do
    let(:genre_id) { Genre::HENTAI_IDS.sample }
    it { is_expected.to eq true }
  end

  context 'banned genre' do
    let(:genre_id) { Genre::BANNED_IDS.sample }
    it { is_expected.to eq true }
  end

  context 'probably_banned genre' do
    let(:genre_id) { Genre::AI_IDS.sample }
    it { is_expected.to eq true }
  end
end
