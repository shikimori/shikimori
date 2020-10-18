set :stage, :production
set :deploy_to, "/home/apps/#{fetch :application}/#{fetch :stage}"

server '88.198.7.123', user: fetch(:user), roles: %w{app web}
server '88.198.7.116', user: fetch(:user), roles: %w{app web db}
