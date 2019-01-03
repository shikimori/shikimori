set :stage, :production
set :deploy_to, "/home/apps/#{fetch :application}/#{fetch :stage}"
set :branch, -> do
  # if !ENV['CODESHIP'] && current_branch != 'master'
    # puts "You can publish to production only the master branch!!!".red
    # abort
  # end
  current_branch
end


server '88.198.7.123', user: fetch(:user), roles: %w{app web main_web}
server '88.198.7.116', user: fetch(:user), roles: %w{app web db}
