describe Animes::Filters::ByLicensor do
  subject { described_class.call scope, terms }

  let(:scope) { Anime.order :id }

  let!(:anime_1) { create :anime, licensors: %w[r] }
  let!(:anime_2) { create :anime, licensors: %w[r] }
  let!(:anime_3) { create :anime, licensors: %w[g] }
  let!(:anime_4) { create :anime }

  context 'positive' do
    context 'r' do
      let(:terms) { 'r' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'g' do
      let(:terms) { 'g' }
      it { is_expected.to eq [anime_3] }
    end

    context 'ANYTHING' do
      let(:terms) { described_class::ANYTHING }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end

    context 'r,g' do
      let(:terms) { 'r,g' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end
  end

  context 'negative' do
    context '!r' do
      let(:terms) { '!r' }
      it { is_expected.to eq [anime_3, anime_4] }
    end

    context '!g' do
      let(:terms) { '!g' }
      it { is_expected.to eq [anime_1, anime_2, anime_4] }
    end

    context '!r,!g' do
      let(:terms) { '!r,!g' }
      it { is_expected.to eq [anime_4] }
    end

    context 'ANYTHING' do
      let(:terms) { "!#{described_class::ANYTHING}" }
      it { is_expected.to eq [anime_4] }
    end
  end

  context 'both' do
    context '!r,!g' do
      let(:terms) { 'r,!g' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context '!r,!g' do
      let(:terms) { '!r,g' }
      it { is_expected.to eq [anime_3] }
    end
  end
end
