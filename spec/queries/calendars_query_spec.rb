describe CalendarsQuery do
  let(:query) { CalendarsQuery.new }

  before do
    create :anime
    create :ongoing_anime, aired_on: Time.zone.now - 1.day
    create :ongoing_anime, duration: 20
    create :ongoing_anime, kind: 'ONA'
    create :ongoing_anime, episodes_aired: 0, aired_on: Time.zone.now - 1.day - 1.month
    create :anons_anime
    create :anons_anime
    create :anons_anime, aired_on: Time.zone.now + 1.week
  end

  it { expect(query.send(:fetch_ongoings).size).to eq(2) }
  it { expect(query.send(:fetch_anonses).size).to eq(3) }

  it { expect(query.fetch.size).to eq(4) }
  it { expect(query.fetch_grouped.size).to eq(2) }
end
