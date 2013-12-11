
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   rake "some:great:rake:task"
# end
#
#   runner "MyModel.some_method"
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :environment, :production
set :output, '/var/www/site/current/log/whenever.log'
set :job_template, "/usr/bin/zsh -i -c ':job'"

# здесь только редкие/долгие таски, которые нельзя на clockwork положить

every 1.day, at: '0:05 am' do
  runner "Delayed::Job.enqueue_uniq AnimeCalendarJob.new, ProcessContestsJob.new, PrepareImportListJob.new(source: :latest, hours_limit: 24*7), CleanupOldLocksJob.new, SakuhindbJob.new(false)"
end

every 1.day, at: '2:30 am' do
  runner "Delayed::Job.enqueue_uniq ImportMangasJob.new, ReadMangaJob.new"
end

every 1.day, at: '3:00 am' do
  runner "Delayed::Job.enqueue_uniq ImportCharactersJob.new"
  command "backup perform --trigger shikimori"
end

every 1.week, at: '3:30 am' do
  runner "Delayed::Job.enqueue_uniq ImportPeopleJob.new, DanbooruTagsJob.new, CleanupOldMessagesJob.new, CleanupUserImagesJob.new, SakuhindbJob.new"
end

every 1.week, at: '4:00 am' do
  runner "Delayed::Job.enqueue_uniq SubtitlesJob.new(latest: true), DeleteBadVideosJob.new"
end

every 1.day, at: '4:30 am' do
  runner "Delayed::Job.enqueue_uniq SubtitlesJob.new(ongoing: true), ActualizeReadMangaLinksJob.new"
end

every 1.day, at: '8:00 am' do
  runner "Delayed::Job.enqueue_uniq VerifyAnimesJob.new, VerifyMangasJob.new, VerifyCharactersJob.new, VerifyPeopleJob.new, VerifyFindanimeLinksJob.new"
end

#every 1.day, at: '0:45 am' do
  #runner "Delayed::Job.enqueue_uniq TorrentsLatestJob.new"
#end

every 1.weeks, at: '3:35 am' do
  runner "Delayed::Job.enqueue_uniq PrepareImportListJob.new(pages_limit: 100)"
end
every 1.weeks, at: '5:35 am' do
  runner "Delayed::Job.enqueue_uniq PrepareImportListJob.new(pages_limit: 100, klass: Manga)"
end

every 2.weeks, at: '3:35 am' do
  #runner "Delayed::Job.enqueue_uniq SakuhindbJob.new(true)"
end

every 32.days, at: '4:13 am' do
  runner "Delayed::Job.enqueue_uniq CharsDescriptionJob.new, UpdatePeopleJobsJob.new"
end

every 2.months, at: '0:09 am' do # макс цифра минус 1
  runner "Delayed::Job.enqueue_uniq PrepareImportListJob.new(pages_limit: 1309, source: :all, klass: Manga)"
end
every 2.months, at: '5:09 am' do # макс цифра минус 1
  runner "Delayed::Job.enqueue_uniq PrepareImportListJob.new(pages_limit: 424, source: :all, klass: Anime)"
end

#every 2.weeks, at: '9:35 am' do
  #runner "Delayed::Job.enqueue_uniq WorldArtJob.new"
#end

#every 1.month, at: '7:25 am' do
  #runner "Delayed::Job.enqueue_uniq AnimedbRuJob.new"
#end

#every 1.day, at: '4:15 am' do
  #runner "Delayed::Job.enqueue_uniq MalLatestJob.new"
#end

#every 1.day, at: ['8:15 am', '3:15 pm', '10:15 pm'] do
  #runner "Delayed::Job.enqueue_uniq MalNewJob.new"
#end

# long tasks
#every 20.minutes do
  #rake "torrents:ongoing"
#end

#every 20.minutes do
  #rake "site:history:process"
#end

#every 1.day, at: '0:15 am' do
  #rake "torrents:latest"
#end

#every 1.day, at: '1:15 am' do
  #rake "mal:import:latest"
#end

#every 1.day, at: '4:15 am' do
  #rake "mal:deploy:latest"
#end

#every 1.day, at: ['6:15 am', '1:15 pm', '8:15 pm'] do
  #rake "mal:import:new"
#end

#every 1.day, at: ['8:15 am', '3:15 pm', '10:15 pm'] do
  #rake "mal:deploy:new"
#end

# Learn more: http://github.com/javan/whenever
