source 'https://rubygems.org'

gem 'rake'
gem 'rails'

gem 'pg'
gem 'dalli' # NOTE: в конфиге мемкеша должна быть опция -I 16M
gem 'redis'
gem 'redis-namespace'

gem 'webpacker'
gem 'slim-rails'
gem 'coffee-rails'
gem 'sassc-rails'
gem 'bourbon'

# turbolinks
# events migration https://github.com/turbolinks/turbolinks/blob/master/src/turbolinks/compatibility.coffee
# new events https://github.com/turbolinks/turbolinks#full-list-of-events
# old events https://github.com/turbolinks/turbolinks-classic
# gem 'turbolinks'
# использовать возможность раздельной загрузки скриптов:
#   в /about сделать подгружаемую highcharts
#   а на странице /animes/id/franchise - d3
gem 'turbolinks', github: 'morr/turbolinks', branch: 'master'

gem 'uglifier'
gem 'non-stupid-digest-assets'

gem 'mal_parser', github: 'shikimori/mal_parser'

gem 'rmagick' # dependence: sudo apt-get install libmagickwand-dev
gem 'rack-cors'
gem 'rack-utf8_sanitizer'
gem 'rack-attack'

gem 'actionpack-action_caching'
gem 'attr_extras'
gem 'state_machine'
gem 'nokogiri'
gem 'paperclip'
gem 'rs_russian', github: 'morr/russian'
gem 'simple_form'
gem 'simple_form-magic_submit', github: 'IngateFuture/simple_form-magic_submit'
#gem 'simple_form-magic_submit', path: '/Users/morr/Develop/simple_form-magic_submit/'
gem 'active_model_serializers'

#gem 'mobylette' # для is_mobile_request в application_controller#show_social?. гем добавляет :mobyle mime type. с ним в ипаде сайт падает сразу после регистрации
gem 'browser' # для детекта internet explorer в рендере shiki_editor
gem 'devise'

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-vkontakte'
gem 'omniauth-twitter'

gem 'pghero'
gem 'sidekiq'
# remove form when https://github.com/mhenrixon/sidekiq-unique-jobs/issues/212 is fixed
gem 'sidekiq-unique-jobs', github: 'morr/sidekiq-unique-jobs', branch: 'master'
gem 'sidekiq-limit_fetch'
gem 'redis-mutex'

gem 'htmlentities' # для конвертации &#29190; -> 爆 у ворлдарта, мала и прочих
#gem 'exception_notification', github: 'smartinez87/exception_notification'
#gem 'slack-notifier'
gem 'awesome_print'
gem 'htmldiff-lcs', github: 'nbudin/htmldiff-lcs', require: 'htmldiff'

gem 'retryable'
gem 'truncate_html'
gem 'acts-as-taggable-on'
gem 'acts_as_list'
gem 'meta-tags'
gem 'enumerize', '2.0.1' # в 2.1.0 Sidekiq::Extensions::DelayedMailer падает с "NoMethodError: undefined method `include?' for nil:NilClass"
gem 'draper'
gem 'cancancan', github: 'morr/cancancan', branch: 'master'
gem 'draper-cancancan' # because https://github.com/CanCanCommunity/cancancan/issues/255
gem 'acts_as_voteable', github: 'morr/acts_as_voteable', branch: 'master'

gem 'unicode' # для downcase русских слов
gem 'icalendar' # для аниме календраря
gem 'activerecord-import' # для быстрого импорта тегов
gem 'amatch', github: 'flori/amatch' # для поиска русских имён из википедии
gem 'ruby-svd', github: 'morr/Ruby-SVD' # для SVD рекомендаций. ruby 2.0
gem 'xxhash' # очень быстрый несекьюрный алгоритм хеширования (для comments_helper)
gem 'faraday'
gem 'faraday_middleware'
gem 'faraday-cookie_jar'

gem 'jbuilder' # для рендеринга json
gem 'rack-contrib', github: 'libc/rack-contrib', branch: 'rack_ruby_2+no-gvb' # для поддержки jsonp в api
gem 'responders' # для json responder'а, который нужен для рендеринга контента на patch и put запросы
gem 'zaru'

gem 'apipie-rails'
gem 'maruku'
gem 'gcm'
gem 'open_uri_redirections' # для работы http->https редиректов. например, при загрузке видео с vimeo (http://vimeo.com/113998423)

gem 'i18n-js'
gem 'rails-i18n'
gem 'i18n-inflector-rails'

gem 'dry-struct'
gem 'chainable_methods'

group :beta, :production do
  gem 'honeybadger'
  gem 'appsignal'
  gem 'newrelic_rpm'
  gem 'lograge'
  gem 'unicorn'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen'

  gem 'letter_opener'
  gem 'mactag'

  gem 'better_errors', github: 'ellimist/better_errors', branch: 'master'
  gem 'binding_of_caller'

  # gem 'web-console'
  # gem 'listen'

  # gem 'rack-mini-profiler'
  # gem 'flamegraph' # for flame graph in rack-mini-profiler
  # gem 'stackprof', require: false # for flamegraph

  gem 'capistrano'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-copy-files', require: false
  #gem 'slackistrano', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'airbrussh', require: false
  # gem 'rails-flog', require: 'flog'
  gem 'active_record_query_trace'

  gem 'foreman'#, github: 'morr/foreman' # для управления бекграунд процессами
end

gem 'byebug'
gem 'colorize'
gem 'marco-polo'
gem 'pry-byebug'
gem 'pry-rails'
gem 'pry-stack_explorer'

group :development, :test do
  gem 'puma'

  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false

  gem 'rspec'
  gem 'spring-commands-rspec'

  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-spring', require: false
  gem 'guard-pow', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-i18n-js', require: false, github: 'fauxparse/guard-i18n-js'
  # gem 'guard-webpack', github: 'imarcelolz/guard-webpack', branch: 'master'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails', require: false
  gem 'factory_girl-seeds', require: false
  gem 'rails-controller-testing' # it allows use `assigns` method in specs
  gem 'state_machine_rspec'
  gem 'rspec-core'
  gem 'rspec-expectations'
  gem 'rspec-mocks'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', require: false
end

gem 'whenever', require: false
gem 'clockwork', require: false

gem 'faye'
# gem 'faye-redis'
gem 'thin'
