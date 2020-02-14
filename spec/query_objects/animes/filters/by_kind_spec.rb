describe Animes::Filters::ByKind do
  subject { described_class.call Anime.order(:id), terms }

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
    let(:terms) { 'tv' }
    it do
      is_expected.to eq [
        anime_1,
        anime_2,
        anime_3,
        anime_4,
        anime_5,
        anime_6,
        anime_7,
        anime_8,
        anime_9
      ]
    end
  end

  context '!tv' do
    let(:terms) { '!tv' }
    it { is_expected.to eq [anime_10] }
  end

  context 'tv_13' do
    let(:terms) { 'tv_13' }
    it { is_expected.to eq [anime_1, anime_2, anime_3, anime_4] }
  end

  context '!tv_13' do
    let(:terms) { '!tv_13' }
    it { is_expected.to eq [anime_5, anime_6, anime_7, anime_8, anime_9, anime_10] }
  end

  context 'tv_24' do
    let(:terms) { 'tv_24' }
    it { is_expected.to eq [anime_5, anime_6, anime_7] }
  end

  context '!tv_24' do
    let(:terms) { '!tv_24' }
    it { is_expected.to eq [anime_1, anime_2, anime_3, anime_4, anime_8, anime_9, anime_10] }
  end

  context 'tv_48' do
    let(:terms) { 'tv_48' }
    it { is_expected.to eq [anime_8, anime_9] }
  end

  context '!tv_48' do
    let(:terms) { '!tv_48' }
    it do
      is_expected.to eq [
        anime_1,
        anime_2,
        anime_3,
        anime_4,
        anime_5,
        anime_6,
        anime_7,
        anime_10
      ]
    end
  end

  context 'multiple terms' do
    context 'positive' do
      let(:terms) { 'tv_13,tv_24' }
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

    context 'negative' do
      let(:terms) { '!tv_13,!tv_24' }
      it { is_expected.to eq [anime_8, anime_9, anime_10] }
    end

    context 'mixed' do
      let(:terms) { 'movie,tv_13,tv_24' }
      it do
        is_expected.to eq [
          anime_1,
          anime_2,
          anime_3,
          anime_4,
          anime_5,
          anime_6,
          anime_7,
          anime_10
        ]
      end
    end

    context 'tv + tv_13' do
      let(:terms) { 'tv,tv_13' }
      it { is_expected.to eq [anime_1, anime_2, anime_3, anime_4] }
    end
  end
end
