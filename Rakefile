# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)
require 'rake'

ENV['RAKE'] = 'true'
#ENV['RAILS_ENV'] = ARGV[1] || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/config/environment")

require 'rake_tasks'

Site::Application.load_tasks

$VERBOSE = nil

namespace :db do
  task :backup do
    print %x(/home/morr/scripts/db_backup.sh)
  end

  namespace :cleanup do
    task :test do
      cache = MalParser.new.cache
      animes = Anime.where(:id.not_in => cache[:animes].keys)
      if animes.count > 0
        print "%d animes can be deleted\n" % animes.count
        print "%s\n" % animes.map {|v| 'http://shikimori.org/animes/%d %s' % [v.id, v.name] }.join("\n")
      end
      characters = Character.where(:id.not_in => cache[:characters].keys)
      print "%d characters can be deleted\n" % characters.count
      people = Person.where(:id.not_in => cache[:people].keys)
      print "%d people can be deleted\n" % people.count
    end

    task :animes do
      cache = MalParser.new.cache
      animes = Anime.where(:id.not_in => cache[:animes].keys)
      print "deleting %d animes\n" % animes.count
      print "%s\n" % animes.map {|v| 'http://shikimori.org/animes/%d %s' % [v.id, v.name] }.join("\n")
      animes.destroy_all
    end

    task :characters do
      cache = MalParser.new.cache
      characters = Character.where(:id.not_in => cache[:characters].keys)
      print "deleting %d characters...\n" % characters.count
      characters.destroy_all
    end

    task :people do
      cache = MalParser.new.cache
      people = Person.where(:id.not_in => cache[:people].keys)
      print "deleting %d people...\n" % people.count
      people.destroy_all
    end
  end
end

namespace :proxy do
  task :get do
    #NewRelic::Agent.manual_start
    ProxyGetJob.new.perform
    #NewRelic::Agent.shutdown
  end

  task :test do
    #NewRelic::Agent.manual_start
    ProxyTestJob.new.perform
    #NewRelic::Agent.shutdown
  end
end


namespace :subtitles do
  task :ongoing do
    #NewRelic::Agent.manual_start
    SubtitlesJob.new.perform
    #NewRelic::Agent.shutdown
  end

  task :pongoing do
    #NewRelic::Agent.manual_start
    SubtitlesTasks.new.pongoing
    #NewRelic::Agent.shutdown
  end

  task :regular do
    #NewRelic::Agent.manual_start
    SubtitlesTasks.new.regular
    #NewRelic::Agent.shutdown
  end

  task :latest do
    #NewRelic::Agent.manual_start
    SubtitlesTasks.new.latest
    #NewRelic::Agent.shutdown
  end

  task :pregular do
    #NewRelic::Agent.manual_start
    SubtitlesTasks.new.pregular
    #NewRelic::Agent.shutdown
  end
end

namespace :torrents do
  task :toshokan do
    #NewRelic::Agent.manual_start
    ToshokanJob.new.perform
    #NewRelic::Agent.shutdown
  end

  task :ongoing do
    #NewRelic::Agent.manual_start
    TorrentsOngoingJob.new.perform
    #NewRelic::Agent.shutdown
  end

  task :regular do
    #NewRelic::Agent.manual_start
    TorrentsTasks.new.regular
    #NewRelic::Agent.shutdown
  end

  task :latest do
    #NewRelic::Agent.manual_start
    TorrentsLatestJob.new.perform
    #NewRelic::Agent.shutdown
  end

  task :slatest do
    #NewRelic::Agent.manual_start
    TorrentsTasks.new.latest
    #NewRelic::Agent.shutdown
  end

  task :all do
    #NewRelic::Agent.manual_start
    TorrentsTasks.new.all
    #NewRelic::Agent.shutdown
  end
end

namespace :import do
  task :animes do
    ImportAnimesJob.new.perform
  end

  task :mangas do
    ImportMangasJob.new.perform
  end

  task :characters do
    ImportCharactersJob.new.perform
  end

  task :people do
    ImportPeopleJob.new.perform
  end
end

namespace :mal do
  task :latest do
    MalLatestJob.new.perform
  end
  task :new do
    MalNewJob.new.perform
  end

  namespace :import do
    task :anime, :anime_id do |task, args|
      #NewRelic::Agent.manual_start
      MalTasks.new.import(args[:anime_id].to_i)
      #NewRelic::Agent.shutdown
    end

    task :all do
      #NewRelic::Agent.manual_start
      MalTasks.new.import_all
      #NewRelic::Agent.shutdown
    end

    task :new do
      #NewRelic::Agent.manual_start
      MalTasks.new.import_new
      #NewRelic::Agent.shutdown
    end

    task :anons do
      #NewRelic::Agent.manual_start
      MalTasks.new.import_anons
      #NewRelic::Agent.shutdown
    end

    task :ongoing do
      #NewRelic::Agent.manual_start
      MalTasks.new.import_ongoing
      #NewRelic::Agent.shutdown
    end

    task :latest do
      #NewRelic::Agent.manual_start
      MalTasks.new.import_latest
      #NewRelic::Agent.shutdown
    end

    task :reset do
      #NewRelic::Agent.manual_start
      MalTasks.new.reset
      #NewRelic::Agent.shutdown
    end

  end

  namespace :deploy do
    task :anime, :anime_id do |task, args|
      MalTasks.new.deploy(args[:anime_id].to_i)
      Rake::Task["site:apply:releases"].execute
    end

    task :all do
      #NewRelic::Agent.manual_start
      MalTasks.new.deploy_all
      Rake::Task["site:apply:releases"].execute
      #NewRelic::Agent.shutdown
    end

    task :new do
      #NewRelic::Agent.manual_start
      MalTasks.new.deploy_new
      Rake::Task["site:apply:releases"].execute
      #NewRelic::Agent.shutdown
    end

    task :anons do
      #NewRelic::Agent.manual_start
      MalTasks.new.deploy_anons
      Rake::Task["site:apply:releases"].execute
      #NewRelic::Agent.shutdown
    end

    task :ongoing do
      #NewRelic::Agent.manual_start
      MalTasks.new.deploy_ongoing
      Rake::Task["site:apply:releases"].execute
      #NewRelic::Agent.shutdown
    end

    task :latest do
      #NewRelic::Agent.manual_start
      MalTasks.new.deploy_latest
      Rake::Task["site:apply:releases"].execute
      #NewRelic::Agent.shutdown
    end
  end
end

namespace :images do
  namespace :reload do
    task :latest do
      #NewRelic::Agent.manual_start
      ImagesTasks.new.reload_latest_animes
      ImagesTasks.new.reload_latest_characters
      Rake::Task["images:apply:fixes"].execute
      #NewRelic::Agent.shutdown
    end

    task :characters do
      #NewRelic::Agent.manual_start
      ImagesTasks.new.reload_characters
      #Rake::Task["images:apply:fixes"].execute
      #NewRelic::Agent.shutdown
    end
  end

  namespace :apply do
    task :fixes do
      #NewRelic::Agent.manual_start
      ImagesTasks.new.apply_fixes
      #NewRelic::Agent.shutdown
    end
  end

  namespace :check do
    task :empty do
      #NewRelic::Agent.manual_start
      ImagesTasks.new.check_empty
      #NewRelic::Agent.shutdown
    end

    task :broken do
      #NewRelic::Agent.manual_start
      ImagesTasks.new.check_broken
      #NewRelic::Agent.shutdown
    end
  end
end

namespace :anime do
  namespace :recollect do
    task :history, :anime_id do |task, args|
      anime_id = args[:anime_id].to_i
      anime = Anime.find(anime_id)
      anime.update_attributes({:status => AnimeStatus::Ongoing, :episodes_aired => 0})
      AnimeHistory.where(:anime_id => anime_id).delete_all

      cache = anime.fill_torrents_cache
      print "%d\t%d\t%s\n" % [cache.size, anime.id, anime.name] if cache
      print "failed for %d\t%s\n" % [anime.id, anime.name] unless cache
    end
  end
end

namespace :ani_db do
  task :fetch_and_merge do
    AniDbJob.new.perform
  end
end

namespace :world_art do
  task :fetch_and_merge do
    WorldArtJob.new.perform
  end
end

namespace :cos_rain do
  task :fetch_and_merge do
    CosRainJob.new.perform
  end
end

namespace :tri_dolki do
  task :fetch_and_merge do
    TriDolkiJob.new.perform
  end
end

namespace :site do
  namespace :apply do
    task :releases do
      released_animes_history = AnimeHistory.where(:action => AnimeHistoryAction::Release).inject({}) do |data,v|
        data[v.anime_id] = v
        data
      end
      released_ids = released_animes_history.map {|k,v| v.anime_id }
      unapplied_releases = Anime.where('id in (%s) and released != null' % released_ids.join(','))#.where("status != '%s'" % AnimeStatus::Released)
      unapplied_releases_ids = unapplied_releases.map {|v| v.id }
      #print "%d releases found\n" % released_ids.count
      print "%d unapplied releases found:\n%s\n" % [unapplied_releases_ids.count, unapplied_releases.map {|v| "\t%s (%d)" % [v.name, v.id] }.join("\n") ]
      unapplied_releases.each do |v|
        v.status = AnimeStatus::Released
        v.released = released_animes_history[v.id].created_at
        v.save
      end
    end
  end

  namespace :delete do
    task :not_found_images do
      deleted_images_ids = [7764,7836,7837,7838,7839,8319,8320,7927,7988,7989,8322,8005,8028,8051,8071,8072,8323,8326,7896,1705,7764,7839,7764,829,7927,8071,4968,7988,7836,827,7988,8028,1383,8322,7989,7838,8051,1462,7896,1134,6341,8072,7837,1133,1704]
      images = Image.where('id in (%s)' % deleted_images_ids.join(','))
      parser = MalParser.new
      images.each {|v| parser.cache[:animes][v.anime_id][:images].delete_if {|k| k[:url] == v[:mal] } }
      parser.save_cache
      images.each {|v| v.destroy }
      print "%d images were deleted:\n%s\n" % [images.count, images.map {|v| "\t%s (%d)" % [v.mal, v.id] }.join("\n") ]
    end
  end

  namespace :history do
    task :process do
      HistoryJob.new.perform
    end
  end
end

namespace :assets do
  task :package do
    Jammit.package! :base_url => "http://shikimori.org/"
  end
end

namespace :cache do
  task :clear do
    Rails.cache.clear
  end
end

namespace :censored do
  task :update do
    ActiveRecord::Base.connection.execute("update animes set censored=true where censored=false and id in (select anime_id from animes_genres where genre_id=%d)" % Genre::HentaiID);
  end
end

namespace :update do
  task :humans do
    content = File.open('public/humans.txt', 'r') {|v| v.read }
    File.open('public/humans.txt', 'w') {|file| file.write(content.sub('<DEPLOY_TIME_MARKER>', DateTime.now.strftime('%Y/%m/%d'))) }
  end
end

namespace :jobs do
  task :restart do
    Delayed::Job.all.select {|job| job.status == 'executing'}.each do |job|
      job.update_attributes(:last_error => nil,
                            :locked_at => nil,
                            :failed_at => nil,
                            :locked_by => nil,
                            :attempts => 0,
                            :created_at => DateTime.now,
                            :run_at => DateTime.now)
    end
  end
end
