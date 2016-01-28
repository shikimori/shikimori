describe ImportAnimeCalendars do
  let(:worker) { ImportAnimeCalendars.new }

  before { Timecop.freeze '2015-06-01' }
  after { Timecop.return }

  describe '#perform', :vcr do
    let!(:ongoing) { create :anime, :ongoing, name: 'Fairy Tail' }
    let!(:anons) { create :anime, :anons, name: 'Prison School' }
    let!(:released) { create :anime, :released, name: 'Yokai Watch' }

    let!(:config_match) { create :anime, :anons, id: 30230, name: 'Diamond no Ace: Second Season' }

    before { NameMatches::Refresh.new.perform Anime.name }
    before { worker.perform }

    it do
      expect(ongoing.anime_calendars).to have(9).items
      expect(anons.anime_calendars).to have(8).items
      expect(released.anime_calendars).to be_empty
      expect(config_match.anime_calendars).to have(9).items
    end
  end
end
