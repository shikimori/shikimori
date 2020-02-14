describe Animes::Filters::ByRating do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, rating: :r }
  let!(:anime_2) { create :anime, rating: :r }
  let!(:anime_3) { create :anime, rating: :g }
  let!(:anime_4) { create :anime, rating: :r_plus }

  context 'inclusive' do
    context 'r' do
      let(:terms) { 'r' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'r' do
      let(:terms) { 'g' }
      it { is_expected.to eq [anime_3] }
    end

    context 'r,g' do
      let(:terms) { 'r,g' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end
  end

  context 'exclusive' do
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
