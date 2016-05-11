set :application, 'shikimori'
set :repo_name, 'shikimori'
set :repo_url, "git@github.com:morr/#{fetch :repo_name}.git"
set :rails_env, fetch(:stage)

#set :bundle_without, [:test]
set :branch, ->{ `git rev-parse --abbrev-ref HEAD`.chomp }
set :scm, :git

set :keep_releases, 5
#set :format, :pretty
set :log_level, :info
# set :pty, true # https://github.com/capistrano/capistrano#a-word-about-ptys

set :slack_team, fetch(:application)
set :slack_token, 'Ir0HqbTOBnhbf8hXGosJBqh6'
set :slack_channel, ->{ '#general' }
set :slack_username, ->{ ENV['USER'] }

set :user, 'devops'
set :group, 'apps'
set :unicorn_user, 'devops'

set :linked_files, %w{
  config/database.yml
  config/secrets.yml
}
set :linked_dirs, %w{
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  public/assets
  public/system
}

def shell_exec command
  execute "source /home/#{fetch :user}/.rvm/scripts/rvm && #{command}"
end

def bundle_exec command, witin_path = "#{self.deploy_to}/current"
  shell_exec "cd #{witin_path} && RAILS_ENV=#{fetch :rails_env} bundle exec #{command}"
end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} upgrade"
    end
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} upgrade"
    end
  end

  namespace :file do
    task :lock do
      on roles(:app) do
        execute "touch /tmp/deploy_#{fetch :application}_#{fetch :stage}.lock"
      end
    end

    task :unlock do
      on roles(:app) do
        execute "rm /tmp/deploy_#{fetch :application}_#{fetch :stage}.lock"
      end
    end
  end

  namespace :i18n_js do
    task :export do
      on roles(:app) do
        bundle_exec 'rake i18n:js:export'
      end
    end
  end
end

namespace :cache do
  task :clear do
    on roles(:app), in: :sequence, wait: 5 do
      bundle_exec "rake tmp:cache:clear"
    end
  end
end

namespace :test do
  task :ruby do
    on roles(:app), in: :sequence, wait: 5 do
      shell_exec "ruby -v"
    end
  end

  task :whoami do
    on roles(:app), in: :sequence, wait: 5 do
      shell_exec "whoami"
    end
  end

  task :git do
    on roles(:app), in: :sequence, wait: 5 do
      execute "git ls-remote git@github.com:morr/#{fetch :repo_name}.git"
    end
  end

  task :bundle do
    on roles(:app), in: :sequence, wait: 5 do
      bundle_exec "rake -T"
    end
  end
end

namespace :unicorn do
  desc "Stop unicorn"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_unicorn_#{fetch :stage} stop"
    end
  end

  desc "Start unicorn"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_unicorn_#{fetch :stage} start"
    end
  end

  desc "Restart unicorn"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_unicorn_#{fetch :stage} upgrade"
    end
  end
end

namespace :sidekiq do
  desc "Quiet sidekiq (stop accepting new work)"
  task :quiet do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_sidekiq_#{fetch :stage} quiet"
    end
  end

  desc "Stop sidekiq"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_sidekiq_#{fetch :stage} stop"
    end
  end

  desc "Start sidekiq"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_sidekiq_#{fetch :stage} start"
    end
  end

  desc "Restart sidekiq"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_sidekiq_#{fetch :stage} restart"
    end
  end
end

namespace :clockwork do
  desc "Stop clockwork"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_clockwork_#{fetch :stage} stop"
    end
  end

  desc "Start clockwork"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_clockwork_#{fetch :stage} start"
    end
  end

  desc "Restart clockwork"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_clockwork_#{fetch :stage} restart"
    end
  end
end

namespace :whenever do
  desc 'Schedule whenever tasks'
  task :schedule do
    on roles(:app), in: :sequence, wait: 5 do
      bundle_exec "whenever --update-crontab #{fetch :application}_#{fetch :stage}"
    end
  end
end

after 'deploy:starting', 'deploy:file:lock'
after 'deploy:published', 'deploy:file:unlock'

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:updated', 'sidekiq:stop'
after 'deploy:reverted', 'sidekiq:stop'
after 'deploy:published', 'sidekiq:start'

before 'deploy:assets:precompile', 'deploy:i18n_js:export'

if fetch(:stage) == :production
  after 'deploy:updated', 'clockwork:stop'
  after 'deploy:reverted', 'clockwork:stop'
  after 'deploy:published', 'clockwork:start'

  after 'deploy:published', 'whenever:schedule'
end

after 'deploy:published', 'unicorn:restart'
after 'deploy:finishing', 'deploy:cleanup'
