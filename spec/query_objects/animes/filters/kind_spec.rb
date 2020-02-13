describe Animes::Filters::Kind do
  subject { described_class.call Anime.all, term }

  let!(:anime_1) { create :anime, :tv, episodes: 13 }
  let!(:anime_2) { create :anime, :tv, episodes: 0, episodes_aired: 13 }
  let!(:anime_3) { create :anime, :tv, episodes: 6 }
  let!(:anime_4) { create :anime, :tv, episodes: 13 }

  let!(:anime_5) { create :anime, :tv, episodes: 17 }
  let!(:anime_6) { create :anime, :tv, episodes: 0, episodes_aired: 17 }
  let!(:anime_7) { create :anime, :tv, episodes: 26 }

  let!(:anime_8) { create :anime, :tv, episodes: 29 }
  let!(:anime_9) { create :anime, :tv, episodes: 0, episodes_aired: 100 }
  let!(:anime_10) { create :anime, :movie }

  context 'tv' do
    let(:term) { 'tv' }
    it { is_expected.to have(9).items }
  end

  context '!tv' do
    let(:term) { '!tv' }
    it { is_expected.to have(1).item }
  end

  context 'tv_13' do
    let(:term) { 'tv_13' }
    it { is_expected.to have(4).items }
  end

  context '!tv_13' do
    let(:term) { '!tv_13' }
    it { is_expected.to have(6).items }
  end

  context 'tv_24' do
    let(:term) { 'tv_24' }
    it { is_expected.to have(3).items }
  end

  context '!tv_24' do
    let(:term) { '!tv_24' }
    it { is_expected.to have(7).items }
  end

  context 'tv_48' do
    let(:term) { 'tv_48' }
    it { is_expected.to have(2).items }
  end

  context '!tv_48' do
    let(:term) { '!tv_48' }
    it { is_expected.to have(8).items }
  end

  context 'multiple terms' do
    context 'positive' do
      let(:term) { 'tv_13,tv_24' }
      it { is_expected.to have(7).items }
    end

    context 'negative' do
      let(:term) { '!tv_13,!tv_24' }
      it { is_expected.to have(3).items }
    end

    context 'mixed' do
      let(:term) { 'movie,tv_13,tv_24' }
      it { is_expected.to have(8).items }
    end

    context 'tv + tv_13' do
      let(:term) { 'tv,tv_13' }
      it { is_expected.to have(4).items }
    end
  end
end
