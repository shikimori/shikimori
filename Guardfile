ignore %r{
  bin | public | node_modules | tmp | .git
}x

guard :bundler do
  watch('Gemfile')
  watch('Gemfile.lock')
end

group :specs, halt_on_fail: true do
  # Note: The cmd option is now required due to the increasing number of ways
  #       rspec may be run, below are examples of the most common uses.
  #  * bundler: 'bundle exec rspec'
  #  * bundler binstubs: 'bin/rspec'
  #  * spring: 'bin/rspec' (This will use spring if running and you have
  #                          installed the spring binstubs per the docs)
  #  * zeus: 'zeus rspec' (requires the server to be started separately)
  #  * 'just' rspec: 'rspec'
  # guard :rspec, cmd: 'bundle exec spring rspec --color --format documentation', all_after_pass: false, all_on_start: false, failed_mode: :keep do
  guard :rspec, cmd: 'bundle exec rspec --color --format documentation', all_after_pass: false, all_on_start: false, failed_mode: :keep do
    require "guard/rspec/dsl"
    dsl = Guard::RSpec::Dsl.new(self)

    # Feel free to open issues for suggestions and improvements

    # RSpec files
    rspec = dsl.rspec
    # watch(rspec.spec_helper) { rspec.spec_dir }
    # watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)

    # Rails files
    rails = dsl.rails(view_extensions: %w(erb haml slim))
    dsl.watch_spec_files_for(rails.app_files)
    dsl.watch_spec_files_for(rails.views)

    watch(rails.controllers) do |m|
      [
        rspec.spec.call("routing/#{m[1]}_routing"),
        rspec.spec.call("controllers/#{m[1]}_controller"),
        rspec.spec.call("acceptance/#{m[1]}")
      ]
    end

    # Rails config changes
    # watch(rails.spec_helper)     { rspec.spec_dir }
    watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
    watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }

    # Capybara features specs
    watch(rails.view_dirs)     { |m| rspec.spec.call("features/#{m[1]}") }
    watch(rails.layouts)       { |m| rspec.spec.call("features/#{m[1]}") }

    # Turnip features and steps
    watch(%r{^spec/acceptance/(.+)\.feature$})
    watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) do |m|
      Dir[File.join("**/#{m[1]}.feature")][0] || "spec/acceptance"
    end

    # watch(%r{^spec/.+_spec\.rb$})
    # watch(%r{^spec/factories/(.+)\.rb$})

    # watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    # # presenters
    # watch(%r{^app/presenters/(.+)_presenter\.rb$})      { |m| "spec/controllers/#{m[1]}_controller_spec.rb" }
    # watch(%r{^app/presenters/(.+)_presenter\.rb$})      { |m| "spec/controllers/#{m[1]}s_controller_spec.rb" }
    # # directos
    # watch(%r{^app/directors/(.+)_director\.rb$})        { |m| "spec/controllers/#{m[1]}_controller_spec.rb" }
    # watch(%r{^app/directors/(.+)_director\.rb$})        { |m| "spec/controllers/#{m[1]}s_controller_spec.rb" }

    # watch('app/models/entry.rb')                        { ["spec/models/entry_spec.rb", "spec/models/topic_spec.rb"] }

    # watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
    # watch(%r{^lib/jobs/(.+)\.rb$})                           { |m| "spec/jobs/#{m[1]}_spec.rb" }
    # watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    # watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
    # #watch('spec/spec_helper.rb')                        { "spec" }
    # watch('app/controllers/application_controller.rb')  { "spec/controllers" }
    # watch('app/controllers/ani_mangas_controller.rb')  { ["spec/controllers/animes_controller_spec.rb", "spec/controllers/mangas_controller_spec.rb"] }

    # # Capybara request specs
    # watch(%r{^app/views/(.+)/.*\.(erb|haml|slim|rabl)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
  end

  guard :rubocop, all_on_start: false, keep_failed: false do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

guard :pow do
  watch '.powrc'
  watch '.powenv'
  watch '.rvmrc'
  watch 'Gemfile'
  watch 'Gemfile.lock'
  watch 'config/application.rb'
  watch 'config/environment.rb'
  watch %r{^config/environments/.*\.rb$}
  watch %r{^config/initializers/.*\.rb$}
  watch %r{^config/middleware/.*\.rb$}
end

guard 'i18n-js' do
  watch(%r{config/locales/.+\.yml})
end

# guard :webpack, config: './config/webpack/development.js' do
  # watch 'package.json'
# end

guard :brakeman, run_on_start: true do
  watch(%r{^app/.+\.(erb|haml|rhtml|rb)$})
  watch(%r{^config/.+\.rb$})
  watch(%r{^lib/.+\.rb$})
  watch('Gemfile')
end
