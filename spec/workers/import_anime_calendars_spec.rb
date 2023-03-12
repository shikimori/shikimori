describe ImportAnimeCalendars do
  let(:worker) { ImportAnimeCalendars.new }

  include_context :timecop, '2015-06-01'

  describe '#perform', :vcr do
    let!(:ongoing) { create :anime, :ongoing, name: 'Hikari no Ou' }
    # let!(:anons) { create :anime, :anons, name: 'Prison School' }
    let!(:released) { create :anime, :released, name: 'Tensei Oujo to Tensai Reijou no Mahou Kakumei' }

    # let!(:config_match) { create :anime, :anons, id: 30230, name: 'Diamond no Ace: Second Season' }

    before { NameMatches::Refresh.new.perform Anime.name }
    subject! { worker.perform }

    it do
      expect(ongoing.anime_calendars).to have(5).items
      expect(ongoing.anime_calendars[0]).to have_attributes(
        episode: 7,
        start_at: Time.zone.parse('Sat, 25 Feb 2023 12:30:00.000000000 MSK +03:00')
      )
      # expect(anons.anime_calendars).to have(8).items
      expect(released.anime_calendars).to be_empty
      # expect(config_match.anime_calendars).to have(9).items
    end
  end
end
