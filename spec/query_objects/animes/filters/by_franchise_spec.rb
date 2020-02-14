describe Animes::Filters::ByFranchise do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, franchise: 'qwe' }
  let!(:anime_2) { create :anime, franchise: 'zxc' }
  let!(:anime_3) { create :anime, franchise: 'zxc' }
  let!(:anime_4) { create :anime }

  context 'positive' do
    context 'zxc' do
      let(:terms) { 'zxc' }
      it { is_expected.to eq [anime_2, anime_3] }
    end

    context 'zxc,qwe' do
      let(:terms) { 'zxc,qwe' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end
  end

  context 'negative' do
    context '!zxc' do
      let(:terms) { '!zxc' }
      it { is_expected.to eq [anime_1, anime_4] }
    end
  end

  context 'both' do
    context 'zxc,!qwe' do
      let(:terms) { 'zxc,!qwe' }
      it { is_expected.to eq [anime_2, anime_3] }
    end
  end
end
