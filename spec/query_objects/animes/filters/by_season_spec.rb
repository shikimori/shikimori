describe Animes::Filters::BySeason do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, aired_on: { year: 2010, month: 2 } }
  let!(:anime_2) { create :anime, aired_on: { year: 2010, month: 12, day: 31 } }
  let!(:anime_3) { create :anime, aired_on: { year: 2009, month: 2 } }
  let!(:anime_4) { create :anime, aired_on: { year: 1979, month: 2 } }

  context 'positive' do
    context 'year' do
      let(:terms) { '2010' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'year_year' do
      let(:terms) { '2009_2010' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }

      context 'left boundry' do
        let(:terms) { '2008_2009' }
        it { is_expected.to eq [anime_3] }
      end

      context 'right boundry' do
        let(:terms) { '2010_2011' }
        it { is_expected.to eq [anime_1, anime_2] }
      end
    end

    context 'season_year' do
      let!(:anime_5) { create :anime, aired_on: { year: 2010 } }
      let!(:anime_6) { create :anime, aired_on: { year: 2010, month: 1 } }
      let(:terms) { 'winter_2010' }
      it { is_expected.to eq [anime_1, anime_6] }
    end

    context 'decade' do
      context 'left boundry' do
        let(:terms) { '200x' }
        it { is_expected.to eq [anime_3] }
      end

      context 'right boundry' do
        let(:terms) { '201x' }
        it { is_expected.to eq [anime_1, anime_2] }
      end
    end

    context 'ancient' do
      let(:terms) { 'ancient' }
      it { is_expected.to eq [anime_4] }
    end
  end

  context 'negative' do
    context '!2010' do
      let(:terms) { '!2010' }
      it { is_expected.to eq [anime_3, anime_4] }
    end
  end

  context 'both' do
    context 'released,!latest' do
      let(:terms) { '2010,!winter_2010' }
      it { is_expected.to eq [anime_2] }
    end
  end
end
