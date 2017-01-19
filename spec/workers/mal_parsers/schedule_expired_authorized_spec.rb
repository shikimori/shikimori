describe MalParsers::ScheduleExpiredAuthorized do
  subject(:call) { worker.perform }
  let(:worker) { described_class.new }

  let(:schedule_interval) do
    MalParsers::ScheduleExpiredAuthorized::SCHEDULE_INTERVAL
  end
  before do
    allow(MalParsers::FetchEntryAuthorized).to receive(:perform_in)
  end

  describe 'filter by status' do
    let!(:anime_1) { create :anime, :anons, :with_mal_id }
    let!(:anime_2) { create :anime, :ongoing, :with_mal_id }

    before { call }

    it do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0, anime_1.id)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, anime_2.id)
    end
  end

  describe 'filter by authorized_imported_at' do
    let!(:anime_1) do
      create :anime, status, :with_mal_id,
        authorized_imported_at: expiration_interval.ago - 1.second
    end
    let!(:anime_2) do
      create :anime, status, :with_mal_id,
        authorized_imported_at: expiration_interval.ago + 1.second
    end
    let!(:anime_3) do
      create :anime, status, :with_mal_id,
        authorized_imported_at: nil
    end

    before { call }

    it 'schedules expired and never imported animes' do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0, anime_1.id)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, anime_2.id)
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(schedule_interval, anime_3.id)
    end
  end

  describe 'filter by mal_id' do
    let!(:anime_1) { create :anime, :anons, :with_mal_id }
    let!(:anime_2) { create :anime, :ongoing }

    before { call }

    it 'does not schedule animes without mal_id' do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0, anime_1.id)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, anime_2.id)
    end
  end

  describe 'max number of animes to schedule' do
    let!(:anime_1) { create :anime, :anons, :with_mal_id }
    let!(:anime_2) { create :anime, :ongoing, :with_mal_id }

    before do
      stub_const(
        'MalParsers::ScheduleExpiredAuthorized::SCHEDULE_INTERVAL',
        13.hours
      )
    end
    before { call }

    it 'schedules not more jobs than can be finished within 24 hours' do
      expect(MalParsers::FetchEntryAuthorized)
        .to have_received(:perform_in)
        .with(0, anime_1.id)
      expect(MalParsers::FetchEntryAuthorized)
        .not_to have_received(:perform_in)
        .with(anything, anime_2.id)
    end
  end
end
