describe Animes::Filters::ByOrigin do
  subject { described_class.call scope, terms }

  let(:scope) { Anime.order :id }

  let!(:anime_1) { create :anime, origin: Types::Anime::Origin[:original] }
  let!(:anime_2) { create :anime, origin: Types::Anime::Origin[:original] }
  let!(:anime_3) { create :anime, origin: Types::Anime::Origin[:manga] }
  let!(:anime_4) { create :anime, origin: Types::Anime::Origin[:novel] }

  context 'positive' do
    context 'original' do
      let(:terms) { Types::Anime::Origin[:original].to_s }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'manga' do
      let(:terms) { Types::Anime::Origin[:manga].to_s }
      it { is_expected.to eq [anime_3] }
    end

    context 'original,manga' do
      let(:terms) { "#{Types::Anime::Origin[:original]},#{Types::Anime::Origin[:manga]}" }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end
  end

  context 'negative' do
    context '!original' do
      let(:terms) { "!#{Types::Anime::Origin[:original]}" }
      it { is_expected.to eq [anime_3, anime_4] }
    end

    context '!manga' do
      let(:terms) { "!#{Types::Anime::Origin[:manga]}" }
      it { is_expected.to eq [anime_1, anime_2, anime_4] }
    end

    context '!original,!manga' do
      let(:terms) { "!#{Types::Anime::Origin[:original]},!#{Types::Anime::Origin[:manga]}" }
      it { is_expected.to eq [anime_4] }
    end
  end

  context 'both' do
    context '!original,!manga' do
      let(:terms) { "#{Types::Anime::Origin[:original]},!#{Types::Anime::Origin[:manga]}" }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context '!original,!manga' do
      let(:terms) { "!#{Types::Anime::Origin[:original]},#{Types::Anime::Origin[:manga]}" }
      it { is_expected.to eq [anime_3] }
    end
  end

  context 'invalid parameter' do
    let(:terms) { %w[s !s].sample }
    it { expect { subject }.to raise_error InvalidParameterError }
  end

  context 'invalid scope' do
    let(:scope) { [Manga.all, Ranobe.all].sample }
    let(:terms) { 'S' }
    it { expect { subject }.to raise_error InvalidParameterError }
  end
end
