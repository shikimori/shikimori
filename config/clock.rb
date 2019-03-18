require File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

module Clockwork
  every(5.minutes, 'pghero.query_stats') { PgHero.capture_query_stats }
  every(1.day, 'pghero.space_stats', at: '00:45') { PgHero.capture_space_stats }

  every 10.minutes, 'toshokan' do
    ImportToshokanTorrents.perform_async true
    # ImportNyaaTorrents.perform_async
  end

  every 30.minutes, 'half-hourly.import', at: ['**:15', '**:45'] do
    MalParsers::FetchPage.perform_async 'anime', 'updated_at', 0, 3
    MalParsers::FetchPage.perform_async 'manga', 'updated_at', 0, 5

    MalParsers::RefreshEntries.perform_async 'anime', 'anons', 12.hours
    MalParsers::RefreshEntries.perform_async 'anime', 'ongoing', 8.hours
    MalParsers::ScheduleExpired.perform_async 'anime'
  end

  every 15.minutes, 'kill-freezed-postgres-queries' do
    KillFreezedPostgresQueries.perform_async
  end

  every 1.hour, 'hourly', at: '**:45' do
    ProxyWorker.perform_async
    # FindAnimeWorker.perform_async :last_3_entries
    # AnimeSpiritWorker.perform_async :last_3_entries
    BadReviewsCleaner.perform_async
  end

  # every 1.day, 'find anime imports', at: ['01:00', '07:00', '13:00', '19:00'] do
    # FindAnimeWorker.perform_async :last_15_entries
    # HentaiAnimeWorker.perform_async :last_15_entries
    # AnimeSpiritWorker.perform_async :two_pages
  # end

  every 1.day, 'daily.stuff', at: '00:02' do
    ImportAnimeCalendars.perform_async
  end

  every 1.day, 'daily.stuff', at: '00:30' do
    MalParsers::ScheduleExpired.perform_async 'manga'
    MalParsers::ScheduleExpired.perform_async 'character'
    MalParsers::ScheduleExpired.perform_async 'person'
    MalParsers::ScheduleMissingPersonRoles.perform_async 'character'
    MalParsers::ScheduleMissingPersonRoles.perform_async 'person'

    SakuhindbImporter.perform_async with_fail: false

    # AnimeLinksVerifier.perform_async

    FinishExpiredAnimes.perform_async

    # AutobanFix.perform_async

    # MalParsers::ScheduleExpiredAuthorized.perform_async

    PgCaches::Cleanup.perform_async
  end

  every 1.day, 'daily.long-stuff', at: '03:00' do
    MalParsers::RefreshEntries.perform_async 'anime', 'latest', 1.week
    # SubtitlesImporter.perform_async :ongoings
    ImagesVerifier.perform_async
    AnimeOnline::FixAnimeVideoAuthors.perform_async
    AnimeOnline::CleanupAnimeVideos.perform_async
    DbEntries::CleanupMalBanned.perform_async
    Votable::CleanupCheatBotVotes.perform_async
    # Users::CleanupDoorkeeperTokens.perform_async
  end

  every 1.day, 'daily.torrents-check', at: '03:00' do
    ImportToshokanTorrents.perform_async false
  end

  every 1.day, 'daily.contests', at: '03:38' do
    Contests::Progress.perform_async
  end

  # every 1.day, 'daily.mangas', at: '04:00' do
    # ReadMangaWorker.perform_async
    # AdultMangaWorker.perform_async
  # end

  every 1.day, 'daily.cleanups', at: '05:00' do
    UserRates::LogsCleaner.perform_async
    ViewingsCleaner.perform_async
  end

  every 1.day, 'daily.statistics', at: '07:00' do
    Achievements::UpdateStatistics.perform_async
  end

  every 1.week, 'weekly.stuff.1', at: 'Monday 00:45' do
    Anidb::ImportDescriptionsJob.perform_async
    Tags::CleanupImageboardsCacheJob.perform_async
    Tags::CleanupCoubCacheJob.perform_async
    # FindAnimeWorker.perform_async :first_page
  end

  every 1.week, 'weekly.stuff.2', at: 'Monday 01:45' do
    # FindAnimeWorker.perform_async :two_pages
    # HentaiAnimeWorker.perform_async :first_page
    OldMessagesCleaner.perform_async
    OldNewsCleaner.perform_async
    UserImagesCleaner.perform_async
    SakuhindbImporter.perform_async with_fail: true
    # SubtitlesImporter.perform_async :latest
    BadVideosCleaner.perform_async
    CleanupScreenshots.perform_async

    MalParsers::FetchPage.perform_async 'anime', 'updated_at', 0, 100
    MalParsers::FetchPage.perform_async 'manga', 'updated_at', 0, 100
  end

  every 1.week, 'weekly.stuff.3', at: 'Monday 02:45' do
    Users::MarkForeverBannedAsCheatBots.perform_async
    AnimesVerifier.perform_async
    MangasVerifier.perform_async
    CharactersVerifier.perform_async
    PeopleVerifier.perform_async
  end

  # every 1.week, 'weekly.vacuum', at: 'Monday 05:00' do
    # VacuumDb.perform_async
  # end

  every 1.week, 'weekly.stuff.cpu_intensive', at: 'Monday 05:45' do
    People::JobsWorker.perform_async
    Animes::UpdateCachedRatesCounts.perform_async
    Animes::FranchisesWorker.perform_async
    NameMatches::Refresh.perform_async Anime.name
    NameMatches::Refresh.perform_async Manga.name
  end

  every 1.week, 'weekly.stuff.cpu_intensive.3', at: 'Thursday 03:45' do
    Tags::ImportDanbooruTagsWorker.perform_async
  end

  every 1.day, 'monthly.very-very-long-coub', at: '22:00', if: lambda { |t| t.day == 10 } do
    Tags::ImportCoubTagsWorker.perform_async
  end

  every 1.day, 'monthly.schedule_missing', at: '05:00', if: lambda { |t| t.day == 28 } do
    MalParsers::ScheduleMissing.perform_async 'anime'
    MalParsers::ScheduleMissing.perform_async 'manga'
    MalParsers::ScheduleMissing.perform_async 'character'
    MalParsers::ScheduleMissing.perform_async 'person'
  end

  # every 1.day, 'monthly.vacuum', at: '05:00', if: lambda { |t| t.day == 28 } do
  #   VacuumDb.perform_async
  # end
end
