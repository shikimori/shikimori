Mactag.configure do |config|
  # Use RVM to locate project gems.
  # config.rvm = false

  # Path to gems. No need to set this when RVM is used!
  # config.gem_home = '/Library/Ruby/Gems/1.8/gems'

  # Name of tags file to create.
  config.tags_file = 'tmp/tags'

  # Command used to create the tags table. {INPUT} and {OUTPUT} are required!
  config.binary = '/usr/local/bin/ctags -e -o {OUTPUT} {INPUT}'
end

Mactag do
  # Index current project.
  #index :lib

  # Index current Rails project.
  index :app, :devise

  # Index all models and helpers.
  # index 'app/models/*.rb', 'app/helpers/*.rb'

  # Index the gems carrierwave and redcarpet.
  # index 'carrierwave', 'redcarpet'

  # Index the gem simple_form version 1.5.2.
  # index 'simple_form', :version => '1.5.2'

  # Index rails.
  # index :rails

  # Index rails except action mailer.
  # index :rails, :except => :actionmailer

  # Index only rails packages activerecord and activesupport.
  # index :rails, :only => %w(activerecord activesupport)

  # Index rails, version 3.1.3.
  # index :rails, :version => '3.1.3'
end
