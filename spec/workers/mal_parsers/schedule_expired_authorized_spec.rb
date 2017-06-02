describe MalParsers::ScheduleExpiredAuthorized do
  subject(:call) { described_class.new.perform }

  let(:schedule_interval) do
    MalParsers::ScheduleExpiredAuthorized::SCHEDULE_INTERVAL
  end
  let(:anons_expiration_interval) do
    MalParsers::ScheduleExpiredAuthorized::ANONS_EXPIRATION_INTERVAL
  end
  let(:ongoing_expiration_interval) do
    MalParsers::ScheduleExpiredAuthorized::ONGOING_EXPIRATION_INTERVAL
  end
  let(:default_expiration_interval) do
    MalParsers::ScheduleExpiredAuthorized::DEFAULT_EXPIRATION_INTERVAL
  end

  let!(:anons_anime) { create :anime, :anons, :with_mal_id }
  let!(:ongoing_anime) { create :anime, :ongoing, :with_mal_id }
  let!(:released_anime) { create :anime, :released, :with_mal_id }

  let!(:manga) { create :manga, :with_mal_id }

  before do
    allow(MalParsers::FetchEntryAuthorized).to receive(:perform_in)
  end

  context 'all animes are scheduled' do
    subject! { call }
    it do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0 * schedule_interval, anons_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(1 * schedule_interval, ongoing_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(2 * schedule_interval, released_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(3 * schedule_interval, manga.id, Manga.name)
    end
  end

  describe 'filter by authorized_imported_at' do
    let(:anons_anime) do
      create :anime, :anons, :with_mal_id,
        authorized_imported_at: anons_expiration_interval.ago - 1.second
    end
    let(:ongoing_anime) do
      create :anime, :ongoing, :with_mal_id,
        authorized_imported_at: ongoing_expiration_interval.ago + 1.second
    end
    let(:released_anime) do
      create :anime, :released, :with_mal_id,
        authorized_imported_at: nil
    end

    subject! { call }

    it 'schedules expired and never imported animes' do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0 * schedule_interval, anons_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, ongoing_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(1 * schedule_interval, released_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(2 * schedule_interval, manga.id, Manga.name)
    end
  end

  describe 'filter by mal_id' do
    let(:anons_anime) { create :anime, :anons, :with_mal_id }
    let(:ongoing_anime) { create :anime, :ongoing }
    let(:released_anime) { create :anime, :released, :with_mal_id }

    subject! { call }

    it 'does not schedule animes without mal_id' do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0 * schedule_interval, anons_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, ongoing_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(1 * schedule_interval, released_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(2 * schedule_interval, manga.id, Manga.name)
    end
  end

  describe 'max number of animes to schedule' do
    before do
      stub_const(
        'MalParsers::ScheduleExpiredAuthorized::SCHEDULE_INTERVAL',
        10.hours
      )
    end
    subject! { call }

    it 'schedules not more jobs than can be finished within 24 hours' do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0 * schedule_interval, anons_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(1 * schedule_interval, ongoing_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, released_anime.id, Anime.name)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, manga.id, Manga.name)
    end
  end
end
