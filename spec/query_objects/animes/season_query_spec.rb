describe Animes::SeasonQuery do
  subject { described_class.call scope, season }
  let(:scope) { Anime.order :id }

  let!(:anime_1) { create :anime, aired_on: Date.parse('2010-02-01') }
  let!(:anime_2) { create :anime, aired_on: Date.parse('2010-06-01').end_of_year }
  let!(:anime_3) { create :anime, aired_on: Date.parse('2009-02-01') }
  let!(:anime_4) { create :anime, aired_on: Date.parse('1979-02-01') }

  context 'scope' do
    let(:scope) { Anime.where id: anime_1.id }
    let(:season) { '2010' }
    it { is_expected.to eq [anime_1] }
  end

  context 'year' do
    let(:season) { '2010' }
    it { is_expected.to eq [anime_1, anime_2] }
  end

  context 'year_year' do
    let(:season) { '2009_2010' }
    it { is_expected.to eq [anime_1, anime_2, anime_3] }

    context 'left boundry' do
      let(:season) { '2008_2009' }
      it { is_expected.to eq [anime_3] }
    end

    context 'right boundry' do
      let(:season) { '2010_2011' }
      it { is_expected.to eq [anime_1, anime_2] }
    end
  end

  context 'season_year' do
    let(:season) { 'winter_2010' }
    it { is_expected.to eq [anime_1] }
  end

  context 'decade' do
    context 'left boundry' do
      let(:season) { '200x' }
      it { is_expected.to eq [anime_3] }
    end

    context 'right boundry' do
      let(:season) { '201x' }
      it { is_expected.to eq [anime_1, anime_2] }
    end
  end

  context 'ancient' do
    let(:season) { 'ancient' }
    it { is_expected.to eq [anime_4] }
  end
end
