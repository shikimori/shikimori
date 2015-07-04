describe ImportAnimeCalendars do
  let(:worker) { ImportAnimeCalendars.new }

  describe '#perform', :vcr do
    let!(:anime_ongoing) { create :anime, :ongoing, name: 'Fairy Tail' }
    let!(:anime_anons) { create :anime, :anons, name: 'Prison School' }
    let!(:anime_released) { create :anime, :released, name: 'Yokai Watch' }

    before { worker.perform }

    it do
      expect(anime_ongoing.anime_calendars).to have(9).items
      expect(anime_anons.anime_calendars).to have(8).items
      expect(anime_released.anime_calendars).to be_empty
    end
  end
end
