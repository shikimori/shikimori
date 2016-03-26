ignore %r{
  bin | public
}x

guard :bundler do
  watch('Gemfile')
  watch('Gemfile.lock')
end

guard :rspec, cmd: 'bundle exec spring rspec --color --format documentation', all_after_pass: false, all_on_start: false, failed_mode: :keep do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/factories/(.+)\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  # presenters
  watch(%r{^app/presenters/(.+)_presenter\.rb$})      { |m| "spec/controllers/#{m[1]}_controller_spec.rb" }
  watch(%r{^app/presenters/(.+)_presenter\.rb$})      { |m| "spec/controllers/#{m[1]}s_controller_spec.rb" }
  # directos
  watch(%r{^app/directors/(.+)_director\.rb$})        { |m| "spec/controllers/#{m[1]}_controller_spec.rb" }
  watch(%r{^app/directors/(.+)_director\.rb$})        { |m| "spec/controllers/#{m[1]}s_controller_spec.rb" }

  watch('app/models/entry.rb')                        { ["spec/models/entry_spec.rb", "spec/models/topic_spec.rb"] }

  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^lib/jobs/(.+)\.rb$})                           { |m| "spec/jobs/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  #watch('spec/spec_helper.rb')                        { "spec" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch('app/controllers/ani_mangas_controller.rb')  { ["spec/controllers/animes_controller_spec.rb", "spec/controllers/mangas_controller_spec.rb"] }

  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml|slim|rabl)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
end

guard :pow do
  watch('.powrc')
  watch('.powenv')
  watch('.rvmrc')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
end
