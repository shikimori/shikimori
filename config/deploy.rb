set :application, 'shikimori'
set :repo_name, 'shikimori'
set :repo_url, "git@github.com:shikimori/#{fetch :repo_name}.git"
set :rails_env, fetch(:stage)

set :user, 'devops'
set :group, 'apps'
set :unicorn_user, 'devops'

set :rbenv_type, :user
set :rbenv_ruby, `cat .ruby-version`.chomp
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} "\
  "RBENV_VERSION=#{fetch(:rbenv_ruby)} "\
  "#{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :linked_files, %w[
  config/database.yml
  config/secrets.yml
]
set :linked_dirs, %w[
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  public/assets
  public/system
  public/packs
  public/.well-known/acme-challenge
]
set :copy_files, %w[node_modules]

set :keep_releases, 5
set :log_level, :info
set :format, :airbrussh

set :branch, ENV['BRANCH'] if ENV['BRANCH']

set :appsignal_config, name: YAML.load_file('config/appsignal.yml')[fetch(:rails_env).to_s]['name']
set :appsignal_revision, `git log --pretty=format:'%h' -n 1 #{fetch(:branch)}`
set :appsignal_env, :production

Airbrussh.configure do |config|
  config.truncate = false
end

# def current_branch
#   ENV['BRANCH'] || `git rev-parse --abbrev-ref HEAD`.chomp
# end

def bundle_exec command, witin_path = "#{self.deploy_to}/current"
  execute "cd #{witin_path} && "\
    "RAILS_ENV=#{fetch :rails_env} #{fetch :rbenv_prefix} "\
    "bundle exec #{command}"
end

namespace :deploy do
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
      on roles(:web) do
        bundle_exec 'rails i18n:js:export', release_path
      end
    end
  end

  namespace :yarn do
    task :install do
      on roles(:app) do
        execute "cd #{release_path} && yarn"
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
      bundle_exec "ruby -v"
    end
  end

  task :whoami do
    on roles(:app), in: :sequence, wait: 5 do
      execute "whoami"
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
      execute "sudo systemctl stop #{fetch :application}_unicorn_#{fetch :stage}"
    end
  end

  desc "Start unicorn"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl start #{fetch :application}_unicorn_#{fetch :stage}"
    end
  end

  desc "Restart unicorn"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl reload #{fetch :application}_unicorn_#{fetch :stage} || sudo systemctl restart #{fetch :application}_unicorn_#{fetch :stage}"
    end
  end
end

namespace :sidekiq do
  desc "Quiet sidekiq (stop accepting new work)"
  task :quiet do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl reload #{fetch :application}_sidekiq_#{fetch :stage} || true"
    end
  end

  desc "Stop sidekiq"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl stop #{fetch :application}_sidekiq_#{fetch :stage}"
    end
  end

  desc "Start sidekiq"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl start #{fetch :application}_sidekiq_#{fetch :stage}"
    end
  end

  desc "Restart sidekiq"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl restart #{fetch :application}_sidekiq_#{fetch :stage}"
    end
  end

  desc "Copy files to public folder so nginx could serve them as static files"
  task :copy_assets do
    on roles(:web), in: :sequence, wait: 5 do
      bundled_gem_path = capture(
        "cd #{release_path} && #{fetch :rbenv_prefix} bundle show sidekiq"
      )
      bundled_assets_path = bundled_gem_path.split("\n")[0] + "/web/assets/."
      execute "cp -R #{bundled_assets_path} #{release_path}/public/sidekiq"
    end
  end
end

namespace :apipie do
  desc "Copy files to public folder so nginx could serve them as static files"
  task :copy_assets do
    on roles(:web), in: :sequence, wait: 5 do
      bundled_gem_path = capture(
        "cd #{release_path} && #{fetch :rbenv_prefix} bundle show apipie-rails"
      )
      bundled_assets_path = bundled_gem_path.split("\n")[0] + "/app/public/apipie/javascripts"
      execute "cp -R #{bundled_assets_path} #{release_path}/public/api/doc"
    end
  end
end

namespace :clockwork do
  desc "Stop clockwork"
  task :stop do
    on roles(:db), in: :sequence, wait: 5 do
      execute "sudo systemctl stop #{fetch :application}_clockwork_#{fetch :stage}"
    end
  end

  desc "Start clockwork"
  task :start do
    on roles(:db), in: :sequence, wait: 5 do
      execute "sudo systemctl start #{fetch :application}_clockwork_#{fetch :stage}"
    end
  end

  desc "Restart clockwork"
  task :restart do
    on roles(:db), in: :sequence, wait: 5 do
      execute "sudo systemctl restart #{fetch :application}_clockwork_#{fetch :stage}"
    end
  end
end

before 'deploy:published', 'sidekiq:copy_assets'
before 'deploy:published', 'apipie:copy_assets'

after 'deploy:starting', 'deploy:file:lock'
after 'deploy:published', 'deploy:file:unlock'

after 'deploy:starting', 'sidekiq:quiet'
# after 'deploy:i18n_js:export', 'sidekiq:quiet'
after 'deploy:updated', 'sidekiq:stop'
after 'deploy:reverted', 'sidekiq:stop'
after 'deploy:published', 'sidekiq:start'

# before 'deploy:assets:precompile', 'deploy:yarn:install'
before 'deploy:assets:precompile', 'deploy:i18n_js:export'

if fetch(:stage) == :production
  after 'deploy:updated', 'clockwork:stop'
  after 'deploy:reverted', 'clockwork:stop'
  after 'deploy:published', 'clockwork:restart'
end

after 'deploy:published', 'unicorn:restart'
after 'deploy:finishing', 'deploy:cleanup'
