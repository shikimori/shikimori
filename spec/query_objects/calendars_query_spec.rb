describe CalendarsQuery do
  let(:query) { described_class.new }
  subject { query.fetch }

  include_context :timecop, '28-12-2015 12:00:00'

  context 'common calendar' do
    let!(:anime_1) { create :anime, name: '1' }

    let!(:anime_2) { create :anime, :ongoing, name: '2', next_episode_at: 1.hour.from_now }
    let!(:anime_3) do
      create :anime, :ongoing, name: '3', duration: 20, next_episode_at: 2.hours.from_now
    end
    let!(:anime_4) { create :anime, :ongoing, :ova, name: '4' }
    let!(:anime_5) do
      create :anime, :ongoing,
        name: '5',
        episodes_aired: 0,
        aired_on: Time.zone.now - 1.day - 1.month
    end

    let!(:anime_6) { create :anime, :anons, name: '6', aired_on: 1.day.from_now }
    let!(:anime_7) { create :anime, :anons, name: '7', aired_on: 2.days.from_now }
    let!(:anime_8) { create :anime, :anons, name: '8', aired_on: 2.days.from_now }

    describe 'ongoings query' do
      it { expect(query.send :fetch_ongoings).to eq [anime_2, anime_3] }
    end

    describe 'announced query' do
      it { expect(query.send :fetch_announced).to eq [anime_6, anime_7, anime_8] }
    end

    it do
      is_expected.to eq [anime_2, anime_3, anime_6, anime_7, anime_8]
      expect(query.fetch_grouped).to have(3).items
    end
  end

  context 'announced' do
    let!(:old) do
      create :anime, :anons,
        name: 'old',
        aired_on: described_class::ANNOUNCED_FROM.ago - 1.day
    end
    let!(:not_old) do
      create :anime, :anons,
        name: 'not_old',
        aired_on: described_class::ANNOUNCED_FROM.ago
    end
    let!(:yesterday) { create :anime, :anons, name: 'yesterday', aired_on: 1.day.ago }
    let!(:today) { create :anime, :anons, name: 'today', aired_on: Time.zone.now }
    let!(:tomorrow) { create :anime, :anons, name: 'tomorrow', aired_on: 1.day.from_now }
    let!(:not_too_early) do
      create :anime, :anons,
        name: 'not_too_early',
        aired_on: described_class::ANNOUNCED_UNTIL.from_now
    end
    let!(:too_yearly) do
      create :anime, :anons,
        name: 'too_early',
        aired_on: described_class::ANNOUNCED_UNTIL.from_now + 1.day
    end

    it { is_expected.to eq [not_old, yesterday, today, tomorrow, not_too_early] }
  end

  context 'before new year' do
    let!(:anime_1) { create :anime, :anons, aired_on: '01-01-2016' }
    let!(:anime_2) { create :anime, :anons, aired_on: '02-01-2016' }

    it { is_expected.to eq [anime_2] }
  end
end
