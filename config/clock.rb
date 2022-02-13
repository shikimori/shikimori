require File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

module Clockwork
  every(5.minutes, 'pghero.query_stats') { PgHero.capture_query_stats }
  every(1.day, 'pghero.space_stats', at: '00:45') { PgHero.capture_space_stats }

  every 10.minutes, 'toshokan' do
    ImportToshokanTorrents.perform_async true
    # ImportNyaaTorrents.perform_async
    NamedLogger.clockwork.info 'toshokan finished'
  end

  every 30.minutes, 'half-hourly.import', at: ['**:15', '**:45'] do
    MalParsers::FetchPage.perform_async 'anime', 'updated_at', 0, 3
    MalParsers::FetchPage.perform_async 'manga', 'updated_at', 0, 5

    MalParsers::RefreshEntries.perform_async 'anime', 'anons', 12.hours
    MalParsers::RefreshEntries.perform_async 'anime', 'ongoing', 8.hours
    MalParsers::ScheduleExpired.perform_async 'anime'

    NamedLogger.clockwork.info 'half-hourly.import finished'
  end

  every 15.minutes, 'kill-freezed-postgres-queries' do
    KillFreezedPostgresQueries.perform_async

    NamedLogger.clockwork.info 'kill-freezed-postgres-queries finished'
  end

  every 1.hour, 'hourly', at: '**:45' do
    # ProxyWorker.perform_async
    BadCritiquesCleaner.perform_async

    NamedLogger.clockwork.info 'hourly finished'
  end

  every 2.hours, '2.hours', at: '**:05' do
    SmotretAnime::ScheduleEpisodeWorkers.perform_async 'a'

    NamedLogger.clockwork.info '2.hours finished'
  end

  every 1.day, 'daily.smotret-anime.1/3', at: '10:02' do
    SmotretAnime::ScheduleEpisodeWorkers.perform_async 'b'

    NamedLogger.clockwork.info 'daily.smotret-anime.1/3 finished'
  end

  every 1.day, 'daily.smotret-anime.2/3', at: '18:02' do
    SmotretAnime::ScheduleEpisodeWorkers.perform_async 'b'

    NamedLogger.clockwork.info 'daily.smotret-anime.2/3 finished'
  end

  every 1.day, 'daily.smotret-anime.3/3', at: '00:02' do
    SmotretAnime::ScheduleEpisodeWorkers.perform_async 'b'
    SmotretAnime::ScheduleEpisodeWorkers.perform_async 'c'

    NamedLogger.clockwork.info 'daily.smotret-anime.3/3 finished'
  end

  every 1.day, 'daily.imports', at: '22:30' do
    MalParsers::RefreshEntries.perform_async 'anime', nil, 4.months
    MalParsers::RefreshEntries.perform_async 'manga', nil, 4.months
    MalParsers::RefreshEntries.perform_async 'character', nil, 4.months
    MalParsers::RefreshEntries.perform_async 'person', nil, 8.months

    NamedLogger.clockwork.info 'daily.imports finished'
  end

  every 1.day, 'daily.imports.2', at: '23:30' do
    MalParsers::ScheduleExpired.perform_async 'manga'
    MalParsers::ScheduleExpired.perform_async 'character'
    MalParsers::ScheduleExpired.perform_async 'person'

    MalParsers::ScheduleMissingPersonRoles.perform_async 'character'
    MalParsers::ScheduleMissingPersonRoles.perform_async 'person'

    NamedLogger.clockwork.info 'daily.imports.2 finished'
  end

  every 1.day, 'daily.misc', at: '00:31' do
    ImportAnimeCalendars.perform_async
    SakuhindbImporter.perform_async with_fail: false
    FinishExpiredAnimes.perform_async
    # MalParsers::ScheduleExpiredAuthorized.perform_async
    PgCaches::Cleanup.perform_async

    # AnimeLinksVerifier.perform_async
    # AutobanFix.perform_async

    NamedLogger.clockwork.info 'daily.misc finished'
  end

  every 1.day, 'daily.misc.2', at: '04:15' do
    ImportToshokanTorrents.perform_async false

    MalParsers::RefreshEntries.perform_async 'anime', 'latest', 1.week
    # SubtitlesImporter.perform_async :ongoings
    DbEntries::CleanupMalBanned.perform_async
    Votable::CleanupCheatBotVotes.perform_async
    Users::CleanupDoorkeeperTokens.perform_async
    Users::MarkAsCompletedUnavailableAnimes.perform_async

    ListImports::Cleanup.perform_async

    NamedLogger.clockwork.info 'daily.misc.2 finished'
  end

  every 1.day, 'daily.contests', at: '03:38' do
    Contests::Progress.perform_async

    NamedLogger.clockwork.info 'daily.contests finished'
  end

  # every 1.day, 'daily.mangas', at: '04:00' do
    # ReadMangaWorker.perform_async
    # AdultMangaWorker.perform_async
  # end

  every 1.day, 'daily.cleanups', at: '05:00' do
    UserRates::LogsCleaner.perform_async
    ViewingsCleaner.perform_async

    NamedLogger.clockwork.info 'daily.cleanups finished'
  end

  every 1.day, 'daily.statistics', at: '06:00' do
    Animes::RefreshStatsWorker.perform_async 'anime'
    Animes::RefreshStatsWorker.perform_async 'manga'
    Achievements::UpdateStatistics.perform_async

    NamedLogger.clockwork.info 'daily.statistics finished'
  end

  every 1.week, 'weekly.stuff.1', at: 'Monday 00:45' do
    # Anidb::ImportDescriptionsJob.perform_async
    Tags::CleanupImageboardsCacheJob.perform_async
    Tags::CleanupCoubCacheJob.perform_async

    NamedLogger.clockwork.info 'weekly.stuff.1 finished'
  end

  every 1.week, 'weekly.stuff.2', at: 'Monday 02:45' do
    Messages::CleanupOutdated.perform_async
    UserImagesCleaner.perform_async
    SakuhindbImporter.perform_async with_fail: true
    # SubtitlesImporter.perform_async :latest
    # BadVideosCleaner.perform_async
    Screenshots::Cleanup.perform_async

    MalParsers::FetchPage.perform_async 'anime', 'updated_at', 0, 100
    MalParsers::FetchPage.perform_async 'manga', 'updated_at', 0, 100

    Users::MarkForeverBannedAsCheatBots.perform_async
    AnimesVerifier.perform_async
    MangasVerifier.perform_async
    CharactersVerifier.perform_async
    PeopleVerifier.perform_async

    NamedLogger.clockwork.info 'weekly.stuff.2 finished'
  end

  # every 1.week, 'weekly.vacuum', at: 'Monday 05:00' do
    # VacuumDb.perform_async
  # end

  every 1.week, 'weekly.stuff.cpu_intensive', at: 'Monday 05:45' do
    People::JobsWorker.perform_async
    Characters::JobsWorker.perform_async

    Animes::UpdateCachedRatesCounts.perform_async
    Animes::FranchisesWorker.perform_async

    NameMatches::Refresh.perform_async Anime.name
    NameMatches::Refresh.perform_async Manga.name

    SmotretAnime::ScheduleLinkWorkers.perform_async

    NamedLogger.clockwork.info 'weekly.stuff.cpu_intensive finished'
  end

  every 1.week, 'weekly.stuff.cpu_intensive.3', at: 'Thursday 03:45' do
    Tags::ImportDanbooruTagsWorker.perform_async

    NamedLogger.clockwork.info 'weekly.stuff.cpu_intensive.3 finished'
  end

  # every 1.day, 'monthly.very-very-long-coub', at: '22:00', if: lambda { |t| t.day == 10 } do
  #   Tags::ImportCoubTagsWorker.perform_async
  # 
  #   NamedLogger.clockwork.info 'monthly.very-very-long-coub finished'
  # end

  every 1.day, 'monthly.images-verifier',
    at: '22:00',
    if: lambda { |t| t.day == 5 || t.day == 13 || t.day == 20 } do
      ImagesVerifier.perform_async

      NamedLogger.clockwork.info 'monthly.images-verifier'
    end

  every 1.week, 'weekly.rebuild-eslastic-indexes', at: 'Friday 03:45' do
    Elasticsearch::RebuildIndexes.perform_async
    NamedLogger.clockwork.info 'weekly.rebuild-eslastic-indexes'
  end

  every 1.day, 'monthly.schedule_missing', at: '05:00', if: lambda { |t| t.day == 28 } do
    MalParsers::ScheduleMissing.perform_async 'anime'
    MalParsers::ScheduleMissing.perform_async 'manga'
    MalParsers::ScheduleMissing.perform_async 'character'
    MalParsers::ScheduleMissing.perform_async 'person'

    NamedLogger.clockwork.info 'monthly.schedule_missing finished'
  end

  every 1.day, 'quarter.animes', at: '05:00', if: lambda { |t| t.day == 1 && (t.month % 4) == 0 } do
    MalParsers::FetchPage.perform_async 'anime', 'name', 0, 99999
  end

  every 1.day, 'quarter.mangas', at: '05:00', if: lambda { |t| t.day == 10 && (t.month % 4) == 0 } do
    MalParsers::FetchPage.perform_async 'manga', 'name', 0, 99999
  end

  # every 1.day, 'monthly.vacuum', at: '05:00', if: lambda { |t| t.day == 28 } do
  #   VacuumDb.perform_async
  # end
end
