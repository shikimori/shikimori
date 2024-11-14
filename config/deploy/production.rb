set :stage, :production
set :deploy_to, "/home/apps/#{fetch :application}/#{fetch :stage}"

server 'shiki', user: fetch(:user), roles: %w{app web db}
