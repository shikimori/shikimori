describe Titles::SeasonTitle do
  let(:title) { Titles::SeasonTitle.new date, format, Anime }

  let(:date) { Date.parse '2015-10-15' }

  describe 'season_year' do
    let(:format) { :season_year }

    it { expect(title.text).to eq 'fall_2015' }
    it { expect(title.url_params).to eq season: title.text, status: nil, type: nil }
    it { expect(title.catalog_title).to eq 'Осень 2015' }
    it { expect(title.short_title).to eq 'Осенний сезон' }
    it { expect(title.full_title).to eq 'Осенний сезон 2015 года' }
  end

  describe 'year' do
    let(:format) { :year }

    it { expect(title.text).to eq '2015' }
    it { expect(title.catalog_title).to eq '2015 год' }
    it { expect(title.short_title).to eq '2015 год' }
    it { expect(title.full_title).to eq 'Аниме 2015 года' }
  end

  describe 'years interval' do
    let(:format) { :years_5 }

    it { expect(title.text).to eq '2011_2015' }
    it { expect(title.catalog_title).to eq '2011-2015' }
  end

  describe 'decade' do
    let(:format) { :decade }

    it { expect(title.text).to eq '201x' }
    it { expect(title.catalog_title).to eq '2010-е годы' }
  end

  describe 'ancient' do
    let(:format) { :ancient }

    it { expect(title.text).to eq 'ancient' }
    it { expect(title.catalog_title).to eq 'Более старые' }
  end
end
