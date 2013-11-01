ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'production'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'clockwork'
include Clockwork

# здесь только частые таски, остальные пока что через whenever

# imports
every(10.minutes, 'history.toshokan') do
  Delayed::Job.enqueue_uniq HistoryJob.new
  Delayed::Job.enqueue_uniq ToshokanJob.new
  Delayed::Job.enqueue_uniq NyaaJob.new
  Delayed::Job.enqueue_uniq KillPassengerZombiesJob.new
end

# NOTICE: отключено пока на MAL антиддос защита
#every(1.minute, 'import', :at => ['**:15', '**:45']) do
  #Delayed::Job.enqueue_uniq PrepareImportListJob.new pages_limit: 3
  #Delayed::Job.enqueue_uniq PrepareImportListJob.new pages_limit: 3, klass: Manga
  #Delayed::Job.enqueue_uniq PrepareImportListJob.new source: :anons, hours_limit: 12
  #Delayed::Job.enqueue_uniq PrepareImportListJob.new source: :ongoing, hours_limit: 8

  #Delayed::Job.enqueue_uniq ImportAnimesJob.new
#end

every(1.minute, 'proxies', :at => '**:45') { Delayed::Job.enqueue_uniq ProxyGetJob.new }
