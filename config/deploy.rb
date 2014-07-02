set :application, 'shikimori'
set :repo_name, 'shikimori'
set :repo_url, "git@github.com:morr/#{fetch :repo_name}.git"
set :rails_env, fetch(:stage)

#set :bundle_without, [:test]
set :branch, ->{ `git rev-parse --abbrev-ref HEAD`.chomp }
set :scm, :git

set :keep_releases, 5
set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :user, 'devops'
set :unicorn_user, 'devops'

#set :whenever_command, [:bundle, :exec, :whenever]
#set :whenever_identifier, "#{fetch :application}_#{fetch :stage}"

set :linked_files, %w{
  config/database.yml
  config/secrets.yml
}
set :linked_dirs, %w{
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  tmp/sessions

  public/images/anime
  public/images/anime_fixed
  public/images/attached_image
  public/images/character
  public/images/cosplay_image
  public/images/group
  public/images/image
  public/images/manga
  public/images/person
  public/images/screenshot
  public/images/studio
  public/images/user
  public/images/user_image
}

def shell_exec command
  execute "source /home/#{fetch :user}/.rvm/scripts/rvm && #{command}"
end

def bundle_exec command
  shell_exec "cd #{deploy_to}/current && RAILS_ENV=#{fetch :rails_env} bundle exec #{command}"
end

namespace :test do
  task :ruby do
    on roles(:app), in: :sequence, wait: 5 do
      shell_exec "ruby -v"
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

#namespace :whenever do
  #desc 'Schedule whenever tasks'
  #task :schedule do
    #on roles(:app), in: :sequence, wait: 5 do
      #bundle_exec "whenever --update-crontab #{fetch :application}_#{fetch :stage}"
    #end
  #end
#end

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

namespace :unicorn do
  desc "Stop unicorn"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} stop"
    end
  end

  desc "Start unicorn"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} start"
    end
  end

  desc "Restart unicorn"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} upgrade"
    end
  end
end

#before 'deploy:restart', 'deploy:set_permissions:chmod'
#before 'deploy:restart', 'deploy:set_permissions:chown'
#before 'deploy:restart', 'deploy:set_permissions:chgrp'
after 'deploy:finishing', 'deploy:cleanup'

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:updated', 'sidekiq:stop'
after 'deploy:reverted', 'sidekiq:stop'
after 'deploy:published', 'sidekiq:start'

after 'deploy:published', 'unicorn:restart'
#after 'deploy:published', 'whenever:schedule'


# ===========================================================
# ===========================================================
# ===========================================================


#require 'rvm/capistrano'
#require 'bundler/capistrano'
#require 'whenever/capistrano'
#require 'sidekiq/capistrano'
#load 'deploy/assets'

#set :application, 'shikimori'
#set :domain, 'shikimori.org'
#set :repository,  'git@github.com:morr/shikimori.git'
#set :branch, 'master'

#set :scm, :git

#set :user, 'morr'
#set :use_sudo, false
#set :deploy_via, :remote_cache
#set :rails_env, 'production'

#role :web, "178.63.23.138"                   # Your HTTP server, Apache/etc
#role :app, "178.63.23.138"                   # This may be the same as your `Web` server
#role :db,  "178.63.23.138", primary: true # This is where Rails migrations will run

#default_run_options[:pty] = true

#task :production do
  #set :deploy_to, "/var/www/site"
  ##set :bundle_without, [:development, :test]
#end

#task :staging do
  #set :deploy_to, "/var/www/staging"
  #set :bundle_without, [:test]
#end

#namespace :deploy do
  #task :start, roles: :app do
    #run "touch #{current_path}/tmp/restart.txt"
  #end

  #task :stop, roles: :app do
    ## Do nothing.
  #end

  #desc "Update the crontab file"
  #task :update_crontab, roles: :app do
    #run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  #end

  #task :restart, roles: :app, except: { no_release: true } do
    #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  #end

  #task :symlink_images do
    #run "
      #ln -nfs /var/www/site/images/anime/ #{release_path}/public/images/anime &&
      #ln -nfs /var/www/site/images/manga/ #{release_path}/public/images/manga &&
      #ln -nfs /var/www/site/images/studio/ #{release_path}/public/images/studio &&
      #ln -nfs /var/www/site/images/character/ #{release_path}/public/images/character &&
      #ln -nfs /var/www/site/images/person/ #{release_path}/public/images/person &&
      #ln -nfs /var/www/site/images/image/ #{release_path}/public/images/image &&
      #ln -nfs /var/www/site/images/attached_image/ #{release_path}/public/images/attached_image &&
      #ln -nfs /var/www/site/images/screenshot/ #{release_path}/public/images/screenshot &&
      #ln -nfs /var/www/site/images/user_image/ #{release_path}/public/images/user_image &&
      #ln -nfs /var/www/site/images/cosplay_image/ #{release_path}/public/images/cosplay_image &&
      #ln -nfs /var/www/site/images/group/ #{release_path}/public/images/group &&
      #ln -nfs /var/www/site/images/user/ #{release_path}/public/images/user"
  #end

  #task :symlink_cache do
    #run "
      #rm -R #{release_path}/tmp &&
      #ln -nfs #{shared_path}/tmp #{release_path}/tmp"
  #end

  #task :symlink_database do
    #run "rm #{release_path}/config/database.yml &&
         #ln -nfs /home/#{user}/shikimori.org/database.yml #{release_path}/config/database.yml"
  #end

  #task :symlink_secret_token do
    #run "rm #{release_path}/config/secret_token.yml &&
         #ln -nfs /home/#{user}/shikimori.org/secret_token.yml #{release_path}/config/secret_token.yml"
    #run "rm #{release_path}/config/secret_key_base.yml &&
         #ln -nfs /home/#{user}/shikimori.org/secret_key_base.yml #{release_path}/config/secret_key_base.yml"
  #end

  #task :symlink_devise_secret_key do
    #run "rm #{release_path}/config/devise_secret_key.yml &&
         #ln -nfs /home/#{user}/shikimori.org/devise_secret_key.yml #{release_path}/config/devise_secret_key.yml"
  #end

  #task :symlink_pepper do
    #run "rm #{release_path}/config/pepper.yml &&
         #ln -nfs /home/#{user}/shikimori.org/pepper.yml #{release_path}/config/pepper.yml"
  #end

  #task :symlink_log do
    #run "ln -nfs #{shared_path}/log #{release_path}/log"
  #end
#end

#namespace :foreman do
  #desc 'Export the Procfile to Ubuntu upstart scripts'
  #task :export, roles: :app do
    #run "cd #{current_path} && rvmsudo bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{current_path}/log/foreman"
  #end

  #desc "Start the application services"
  #task :start, roles: :app do
    #run "rvmsudo start #{application}"
  #end

  #desc "Stop the application services"
  #task :stop, roles: :app do
    #run "rvmsudo stop #{application}"
  #end

  #desc "Restart the application services"
  #task :restart, roles: :app do
    #run "rvmsudo start #{application} || rvmsudo restart #{application}"
  #end
#end

#after 'deploy:finalize_update', 'deploy:symlink_database'
#after 'deploy:finalize_update', 'deploy:symlink_secret_token'
#after 'deploy:finalize_update', 'deploy:symlink_devise_secret_key'
#after 'deploy:finalize_update', 'deploy:symlink_pepper'
#after 'deploy:finalize_update', 'deploy:symlink_cache'
#after 'deploy:finalize_update', 'deploy:symlink_images'
#after 'deploy:finalize_update', 'deploy:symlink_log'
#after 'deploy:update_code', 'deploy:migrate'

#after 'deploy:update', 'foreman:export'  # Export foreman scripts
#after 'deploy:update', 'foreman:restart' # Restart application scripts
#after 'deploy:update', 'deploy:update_crontab'
#after 'deploy:update', 'deploy:cleanup'
