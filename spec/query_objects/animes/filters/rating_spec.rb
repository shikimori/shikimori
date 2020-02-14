describe Animes::Filters::Rating do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, rating: :r }
  let!(:anime_2) { create :anime, rating: :r }
  let!(:anime_3) { create :anime, rating: :g }
  let!(:anime_4) { create :anime, rating: :r_plus }

  context 'inclusive' do
    context 'r' do
      let(:terms) { 'r' }
      it { is_expected.to have(2).items }
    end

    context 'r' do
      let(:terms) { 'g' }
      it { is_expected.to have(1).item }
    end

    context 'r,g' do
      let(:terms) { 'r,g' }
      it { is_expected.to have(3).items }
    end
  end

  context 'exclusive' do
    context '!r' do
      let(:terms) { '!r' }
      it { is_expected.to have(2).items }
    end

    context '!g' do
      let(:terms) { '!g' }
      it { is_expected.to have(3).items }
    end

    context '!r,!g' do
      let(:terms) { '!r,!g' }
      it { is_expected.to have(1).item }
    end
  end

  context 'both' do
    context '!r,!g' do
      let(:terms) { 'r,!g' }
      it { is_expected.to have(2).items }
    end

    context '!r,!g' do
      let(:terms) { '!r,g' }
      it { is_expected.to have(1).item }
    end
  end
end
