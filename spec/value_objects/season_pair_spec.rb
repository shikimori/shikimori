describe SeasonPair do
  let(:pair) { SeasonPair.new date }
  let(:date) { Time.zone.now }

  before { Timecop.freeze '2015-10-15' }
  after { Timecop.return }

  it { expect(pair.to_s).to eq 'fall_2015' }
  it { expect(pair.season_year).to eq ['fall_2015', 'Осень 2015'] }
  it { expect(pair.year).to eq ['2015', '2015 год'] }
  it { expect(pair.years(5)).to eq ['2011_2015', '2011-2015'] }
  it { expect(pair.decade).to eq ['201x', '2010е годы'] }
  it { expect(pair.ancient).to eq ['ancient', 'Более старые'] }
end
