require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

module Clockwork
  every 10.minutes, 'history.toshokan' do
    HistoryWorker.perform_async
    ImportToshokanTorrents.perform_async
    ImportNyaaTorrents.perform_async
    # ProxyWorker.perform_async(true)
    SidekiqHeartbeat.new.perform
  end

  every 30.minutes, 'half-hourly.import', at: ['**:15', '**:45'] do
    MalParsers::FetchPage.perform_async 'anime', 'updated_at', 0, 3
    MalParsers::FetchPage.perform_async 'manga', 'updated_at', 0, 5

    MalParsers::RefreshEntries.perform_async 'anime', 'anons', 12.hours
    MalParsers::RefreshEntries.perform_async 'anime', 'ongoing', 8.hours
    MalParsers::ScheduleExpired.perform_async 'anime'
  end

  every 30.minutes, 'half-hourly.import.another', at: ['**:00', '**:30'] do
    PostgresFix.perform_async
  end

  every 1.hour, 'hourly', at: '**:45' do
    ProxyWorker.perform_async(false)
    # FindAnimeWorker.perform_async :last_3_entries
    # AnimeSpiritWorker.perform_async :last_3_entries
    BadReviewsCleaner.perform_async
  end

  every 1.day, 'find anime imports', at: ['01:00', '07:00', '13:00', '19:00'] do
    # FindAnimeWorker.perform_async :last_15_entries
    # HentaiAnimeWorker.perform_async :last_15_entries
    # AnimeSpiritWorker.perform_async :two_pages
  end

  every 1.day, 'daily.stuff', at: '00:02' do
    ImportAnimeCalendars.perform_async
    ProgressContests.perform_async
  end

  every 1.day, 'daily.stuff', at: '00:30' do
    MalParsers::ScheduleExpired.perform_async 'manga'
    MalParsers::ScheduleExpired.perform_async 'character'
    MalParsers::ScheduleExpired.perform_async 'person'
    MalParsers::ScheduleMissingPersonRoles.perform_async 'character'
    MalParsers::ScheduleMissingPersonRoles.perform_async 'person'

    SakuhindbImporter.perform_async with_fail: false
    ReadMangaLinksWorker.perform_async

    AnimesVerifier.perform_async
    MangasVerifier.perform_async
    CharactersVerifier.perform_async
    PeopleVerifier.perform_async
    # AnimeLinksVerifier.perform_async

    FinishExpiredAnimes.perform_async

    # AutobanFix.perform_async

    MalParsers::ScheduleExpiredAuthorized.perform_async
  end

  every 1.day, 'daily.long-stuff', at: '03:00' do
    MalParsers::RefreshEntries.perform_async 'anime', 'latest', 1.week
    SubtitlesImporter.perform_async :ongoings
    ImagesVerifier.perform_async
    FixAnimeVideoAuthors.perform_async
  end

  every 1.day, 'daily.mangas', at: '04:00' do
    ReadMangaWorker.perform_async
    AdultMangaWorker.perform_async
  end

  every 1.day, 'daily.viewings_cleaner', at: '05:00' do
    ViewingsCleaner.perform_async
  end

  every 1.week, 'weekly.vacuum', at: 'Monday 05:00' do
    VacuumDb.perform_async
  end

  every 1.week, 'import anidb descriptions', at: 'Monday 02:00' do
    Anidb::ImportDescriptionsJob.perform_async
  end

  # every 1.week, 'weekly.stuff', at: 'Thursday 01:45' do
    # FindAnimeWorker.perform_async :first_page
  # end

  every 1.week, 'weekly.stuff', at: 'Monday 01:45' do
    # FindAnimeWorker.perform_async :two_pages
    # HentaiAnimeWorker.perform_async :first_page
    DanbooruTagsImporter.perform_async
    OldMessagesCleaner.perform_async
    OldNewsCleaner.perform_async
    UserImagesCleaner.perform_async
    SakuhindbImporter.perform_async with_fail: true
    SubtitlesImporter.perform_async :latest
    BadVideosCleaner.perform_async
    CleanupScreenshots.perform_async

    MalParsers::FetchPage.perform_async 'anime', 'updated_at', 0, 100
    MalParsers::FetchPage.perform_async 'manga', 'updated_at', 0, 100

    PeopleJobsActualzier.perform_async
  end

  every 1.week, 'weekly.stuff', at: 'Monday 05:45' do
    NameMatches::Refresh.perform_async Anime.name
  end

  every 1.week, 'weekly.stuff', at: 'Monday 06:15' do
    NameMatches::Refresh.perform_async Manga.name
  end
end
