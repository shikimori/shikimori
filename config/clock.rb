ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'production'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'clockwork'

module Clockwork
  every 10.minutes, 'history.toshokan' do
    HistoryWorker.perform_async
    ToshokanTorrentsImporter.perform_async
    NyaaTorrentsImporter.perform_async
    #Delayed::Job.enqueue_uniq KillPassengerZombiesJob.new
  end

  every 30.minutes, 'half-hourly.import', at: ['**:15', '**:45'] do
    ImportListWorker.perform_async pages_limit: 3
    ImportListWorker.perform_async pages_limit: 3, type: Manga.name
    ImportListWorker.perform_async source: :anons, hours_limit: 12
    ImportListWorker.perform_async source: :ongoing, hours_limit: 8

    AnimesImporter.perform_async
  end

  every 1.day, 'find anime imports', at: ['01:00', '07:00', '13:00', '19:00'] do
    FindAnimeWorker.perform_async :last_15_entries
  end

  every 1.hour, 'hourly', at: '**:45' do
    ProxyWorker.perform_async
    FindAnimeWorker.perform_async :last_3_entries
  end

  every 1.day, 'daily.stuff', at: '00:02' do
    AnimeCalendarsImporter.perform_async
    ContestsWorker.perform_async
    SakuhindbImporter.perform_async with_fail: false
    OldLocksCleaner.perform_async
    ReadMangaLinksWorker.perform_async

    AnimesVerifier.perform_async
    MangasVerifier.perform_async
    CharactersVerifier.perform_async
    PeopleVerifier.perform_async
    AnimeLinksVerifier.perform_async
  end

  every 1.day, 'daily.log-stuff', at: '03:00' do
    ImportListWorker.perform_async source: :latest, hours_limit: 24*7
    SubtitlesImporter.perform_async mode: :ongoings
  end

  every 1.day, 'daily.mangas', at: '04:00' do
    MangasImporter.perform_async
    ReadMangaWorker.perform_async
    AdultMangaWorker.perform_async
  end

  every 1.day, 'daily.characters', at: '03:00' do
    CharactersImporter.perform_async
  end

  every 1.week, 'weekly.stuff', at: 'Monday 01:45' do
    FindAnimeWorker.perform_async :first_page
    PeopleImporter.perform_async
    DanbooruTagsImporter.perform_async
    OldMessagesCleaner.perform_async
    UserImagesCleaner.perform_async
    SakuhindbImporter.perform_async with_fail: true
    SubtitlesImporter.perform_async mode: :latest
    BadVideosCleaner.perform_async

    ImportListWorker.perform_async pages_limit: 100
    ImportListWorker.perform_async pages_limit: 100, type: Manga.name
    PeopleJobsActualzier.perform_async
  end
end
