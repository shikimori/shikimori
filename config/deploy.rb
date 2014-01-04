require 'rvm/capistrano'
require 'bundler/capistrano'
require 'whenever/capistrano'
load 'deploy/assets'

set :application, 'shikimori'
set :domain, 'shikimori.org'
set :repository,  'git@github.com:morr/shikimori.git'
set :branch, 'master'

set :bundle_cmd, "LANG='en_US.UTF-8' bundle"

set :scm, :git

set :user, 'morr'
set :use_sudo, false
set :deploy_via, :remote_cache
set :rails_env, 'production'

set :delayed_job_args, "-n 5"

role :web, "178.63.23.138"                   # Your HTTP server, Apache/etc
role :app, "178.63.23.138"                   # This may be the same as your `Web` server
role :db,  "178.63.23.138", :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true

task :production do
  set :deploy_to, "/var/www/site"
  #set :bundle_without, [:development, :test]
end

task :staging do
  set :deploy_to, "/var/www/staging"
  set :bundle_without, [:test]
end

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_images do
    run "
      ln -nfs /var/www/site/images/anime/ #{release_path}/public/images/anime &&
      ln -nfs /var/www/site/images/manga/ #{release_path}/public/images/manga &&
      ln -nfs /var/www/site/images/studio/ #{release_path}/public/images/studio &&
      ln -nfs /var/www/site/images/character/ #{release_path}/public/images/character &&
      ln -nfs /var/www/site/images/person/ #{release_path}/public/images/person &&
      ln -nfs /var/www/site/images/image/ #{release_path}/public/images/image &&
      ln -nfs /var/www/site/images/attached_image/ #{release_path}/public/images/attached_image &&
      ln -nfs /var/www/site/images/screenshot/ #{release_path}/public/images/screenshot &&
      ln -nfs /var/www/site/images/user_image/ #{release_path}/public/images/user_image &&
      ln -nfs /var/www/site/images/screenshot/ #{release_path}/public/images/screenshot &&
      ln -nfs /var/www/site/images/cosplay_image/ #{release_path}/public/images/cosplay_image &&
      ln -nfs /var/www/site/images/group/ #{release_path}/public/images/group &&
      ln -nfs /var/www/site/images/user/ #{release_path}/public/images/user"
  end

  task :symlink_cache do
    run "
      rm -R #{release_path}/tmp &&
      ln -nfs #{shared_path}/tmp #{release_path}/tmp"
  end

  task :symlink_database do
    run "rm #{release_path}/config/database.yml &&
         ln -nfs /home/#{user}/shikimori.org/database.yml #{release_path}/config/database.yml"
  end

  task :symlink_secret_token do
    run "rm #{release_path}/config/secret_token.yml &&
         ln -nfs /home/#{user}/shikimori.org/secret_token.yml #{release_path}/config/secret_token.yml"
  end

  task :symlink_devise_secret_key do
    run "rm #{release_path}/config/devise_secret_key.yml &&
         ln -nfs /home/#{user}/shikimori.org/devise_secret_key.yml #{release_path}/config/devise_secret_key.yml"
  end

  task :symlink_pepper do
    run "rm #{release_path}/config/pepper.yml &&
         ln -nfs /home/#{user}/shikimori.org/pepper.yml #{release_path}/config/pepper.yml"
  end

  task :symlink_log do
    run "ln -nfs #{shared_path}/log #{release_path}/log"
  end
end

namespace :delayed_job do
  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

  def args
    fetch(:delayed_job_args, "")
  end

  def roles
    fetch(:delayed_job_server_role, :app)
  end

  def start
    run "cd #{current_path};#{rails_env} script/delayed_job start #{args}"
  end

  def stop
    run "cd #{current_path};#{rails_env} script/delayed_job stop"
  end

  desc "Stop the delayed_job process"
  task :mystop, :roles => lambda { roles } do
    stop
  end

  desc "Start the delayed_job process"
  task :mystart, :roles => lambda { roles } do
    start
  end

  desc "*HACK* Restart the delayed_job process"
  task :myrestart do
    stop
    enforce_stop_delayed_job
    run "cd #{current_path}/ && RAILS_ENV=production bundle exec rake jobs:restart"
    start
  end

  # Send SIGTERM to delayed_job associated with current logfile and then
  # wait for every delayed_job to finish
  def enforce_stop_delayed_job
    run %Q{
      lsof '#{current_path}/log/delayed_job.log' | awk '/^ruby/ { system("kill " $2) }' ;
      COUNT=1;
      until [ $COUNT -eq 0 ]; do
        COUNT=`lsof '#{current_path}/log/delayed_job.log' | grep '^ruby' |wc -l` ;
        echo 'waiting for delayed_job to end' ;
        sleep 2 ;
      done
    }.split("\n").join('')
  end
end

namespace :foreman do
  desc 'Export the Procfile to Ubuntu upstart scripts'
  task :export, :roles => :app do
    run "cd #{current_path} && rvmsudo bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{current_path}/log/foreman"
  end

  desc "Start the application services"
  task :start, :roles => :app do
    run "rvmsudo start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    run "rvmsudo stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "rvmsudo start #{application} || rvmsudo restart #{application}"
  end
end

after 'deploy:finalize_update', 'deploy:symlink_database'
after 'deploy:finalize_update', 'deploy:symlink_secret_token'
after 'deploy:finalize_update', 'deploy:symlink_devise_secret_key'
after 'deploy:finalize_update', 'deploy:symlink_pepper'
after 'deploy:finalize_update', 'deploy:symlink_cache'
after 'deploy:finalize_update', 'deploy:symlink_images'
after 'deploy:finalize_update', 'deploy:symlink_log'
after 'deploy:update_code', 'deploy:migrate'

after 'deploy:update', 'foreman:export'  # Export foreman scripts
after 'deploy:update', 'foreman:restart' # Restart application scripts
after 'deploy:update', 'deploy:update_crontab'
after 'deploy:update', 'deploy:cleanup'

after 'deploy:stop',    'delayed_job:mystop'
after 'deploy:start',   'delayed_job:mystart'
after 'deploy:restart', 'delayed_job:myrestart'

