describe Animes::Filters::ByDuration do
  subject { described_class.call scope, terms }

  let(:scope) { Anime.order(:id) }

  let!(:anime_1) { create :anime, duration: 0 }
  let!(:anime_2) { create :anime, duration: 10 }

  let!(:anime_3) { create :anime, duration: 20 }
  let!(:anime_4) { create :anime, duration: 20 }

  let!(:anime_5) { create :anime, duration: 35 }
  let!(:anime_6) { create :anime, duration: 35 }
  let!(:anime_7) { create :anime, duration: 35 }

  context 'positive' do
    context 'S' do
      let(:terms) { 'S' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'D' do
      let(:terms) { 'D' }
      it { is_expected.to eq [anime_3, anime_4] }
    end

    context 'F' do
      let(:terms) { 'F' }
      it { is_expected.to eq [anime_5, anime_6, anime_7] }
    end

    context 'S,D,F' do
      let(:terms) { 'S,D,F' }
      it do
        is_expected.to eq [
          anime_1,
          anime_2,
          anime_3,
          anime_4,
          anime_5,
          anime_6,
          anime_7
        ]
      end
    end
  end

  context 'negative' do
    context '!S' do
      let(:terms) { '!S' }
      it { is_expected.to eq [anime_3, anime_4, anime_5, anime_6, anime_7] }
    end

    context '!D' do
      let(:terms) { '!D' }
      it { is_expected.to eq [anime_1, anime_2, anime_5, anime_6, anime_7] }
    end

    context '!S,!F' do
      let(:terms) { '!S,!F' }
      it { is_expected.to eq [anime_3, anime_4] }
    end
  end

  context 'both' do
    context 'S,!F' do
      let(:terms) { 'S,!F' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context '!S,F' do
      let(:terms) { '!S,F' }
      it { is_expected.to eq [anime_5, anime_6, anime_7] }
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
