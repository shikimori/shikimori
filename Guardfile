ignore [%r{^bin/*}, %r{^db/*}, %r{^log/*}, %r{^public/*}, %r{^tmp/*}]

guard :bundler do
  watch('Gemfile')
end

guard :rspec, cmd: 'rspec --color --format nested --drb', all_after_pass: false, all_on_start: false, failed_mode: :focus do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/factories/(.+)\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  watch(%r{^spec/.+_spec\.rb$})
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

guard :spork, wait: 60, cucumber_env: { 'RAILS_ENV' => 'test' }, rspec_env: { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Guardfile')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb')# { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
end

#guard :livereload do
  #watch(%r{app/views/.+\.(erb|haml|slim)$})
  #watch(%r{app/helpers/.+\.rb})
  #watch(%r{app/assets/.+\.(css|js|coffee|scss|sass|html)})
  #watch(%r{config/locales/.+\.yml})
#end
