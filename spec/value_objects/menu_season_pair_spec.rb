describe MenuSeasonPair do
  let(:pair) { MenuSeasonPair.new date }
  let(:date) { Time.zone.now }

  before { Timecop.freeze '2015-10-15' }
  after { Timecop.return }

  it do
    expect(pair.season_year).to eq [
      'fall_2015', 'Осенний сезон', 'Осенний сезон 2015 года'
    ]
    expect(pair.year).to eq [
      '2015', '2015 год', 'Аниме 2015 года'
    ]
  end
end
