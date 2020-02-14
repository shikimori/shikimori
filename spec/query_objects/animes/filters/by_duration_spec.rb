describe Animes::Filters::ByDuration do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, duration: 10 }
  let!(:anime_2) { create :anime, duration: 20 }
  let!(:anime_3) { create :anime, duration: 20 }
  let!(:anime_4) { create :anime, duration: 35 }
  let!(:anime_5) { create :anime, duration: 35 }
  let!(:anime_6) { create :anime, duration: 35 }

  context 'inclusive' do
    context 'S' do
      let(:terms) { 'S' }
      it { is_expected.to have(1).item }
    end
    context 'D' do
      let(:terms) { 'D' }
      it { is_expected.to have(2).items }
    end
    context 'F' do
      let(:terms) { 'F' }
      it { is_expected.to have(3).items }
    end
    context 'S,D,F' do
      let(:terms) { 'S,D,F' }
      it { is_expected.to have(6).items }
    end
  end

  context 'exclusive' do
    context '!S' do
      let(:terms) { '!S' }
      it { is_expected.to have(5).items }
    end
    context '!D' do
      let(:terms) { '!D' }
      it { is_expected.to have(4).items }
    end
    context '!S,!F' do
      let(:terms) { '!S,!F' }
      it { is_expected.to have(2).items }
    end
  end

  context 'both' do
    context 'S,!F' do
      let(:terms) { 'S,!F' }
      it { is_expected.to have(1).item }
    end
    context '!S,F' do
      let(:terms) { '!S,F' }
      it { is_expected.to have(3).items }
    end
  end
end
