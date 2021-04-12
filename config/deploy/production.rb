set :stage, :production
set :deploy_to, "/home/apps/#{fetch :application}/#{fetch :stage}"

server '135.181.210.175', user: fetch(:user), roles: %w{app web db}
