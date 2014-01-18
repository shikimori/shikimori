source 'https://rubygems.org'

gem 'rake'
gem 'rails', '3.2.16'

gem 'mysql2'
# NOTE: в конфиге мемкеша должна быть опция -I 16M
gem 'dalli'
gem 'redis'
gem 'therubyracer'

gem 'rmagick', require: 'RMagick' # dependence: sudo apt-get install libmagickwand-dev
gem 'capistrano'
gem 'rvm-capistrano'
gem 'marco-polo'

gem 'attribute-defaults'
gem 'state_machine'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'nokogiri'
gem 'paperclip', '2.4.3'
gem 'russian', github: 'yaroslav/russian'
gem 'metrika'
gem 'simple_form'
gem 'strong_parameters'
# TODO: удалить строчку с переходом на rails 4
gem 'active_model_serializers'

gem 'devise'
gem 'devise-async' # асинхронная отсылка писем для devise

gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'sidekiq-limit_fetch'
gem 'sinatra', '>= 1.3.0', require: nil

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-vkontakte'
gem 'omniauth-twitter'

gem 'formtastic'
gem 'bb-ruby'
gem 'htmlentities' # для конвертации &#29190; -> 爆 у ворлдарта, мала и прочих
gem 'newrelic_rpm'
gem 'exception_notification'
gem 'awesome_print'
gem 'ruby-progressbar', github: 'morr/ruby-progressbar'
gem 'htmldiff', github: 'myobie/htmldiff'

group :assets do
  gem 'sass-rails'
  #gem 'susy', '~> 2.0.0.alpha.2'
  gem 'susy', '1.0.8'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'turbo-sprockets-rails3'
  gem 'compass-rails'
end

gem 'truncate_html'
gem 'squeel'
gem 'acts-as-taggable-on'
gem 'uuid'
gem 'meta-tags', github: 'morr/meta-tags', require: 'meta_tags'
gem 'enumerize'
gem 'draper'
# TODO: удалить после перехода на rails 4
gem 'cache_digests'

gem 'unicode' # для downcase русских слов
gem 'quote_extractor', github: 'morr/quote_extractor', tag: 'v0.0.2'
gem 'slim-rails'
gem 'icalendar' # для аниме календраря
gem 'activerecord-import' # для быстрого импорта тегов
gem 'amatch', github: 'flori/amatch' # для поиска русских имён из википедии
gem 'ruby-svd', github: 'morr/Ruby-SVD' # для SVD рекомендаций. ruby 2.0

gem 'rabl' # для рендеринга json

gem 'rest-client'
gem 'postmark-rails'
gem 'apipie-rails'


group :production, :development do # чёртов гем ломает присвоение ассоциаций в FactoryGirl, и я не знаю, как это быстро починить другим способом
  gem 'composite_primary_keys' # для составного праймари кея у CommentView и EntryView
end

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'sextant'
  gem 'mactag'
  gem 'better_errors'
  #gem 'sprockets_better_errors'
  gem 'binding_of_caller'#, github: 'badosu/binding_of_caller'
  gem 'sql-logging'
end

gem 'marco-polo'
gem 'pry-rails'

group :test, :development do
  gem 'rspec-rails'

  gem 'vcr'
  gem 'capybara'
  gem 'shoulda'
  gem 'shoulda-matchers'
  gem 'database_rewinder'

  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false

  gem 'spork'
  gem 'guard', '1.8.2'
  gem 'listen', '1.3.0'
  gem 'guard-rspec', '3.0.2'
  gem 'guard-spork'
  gem 'guard-livereload'

  gem 'webmock', '1.13'

  gem 'factory_girl_rails', require: false
  #gem 'parallel_tests'
  #gem 'rack-mini-profiler'
end

gem 'acts_as_voteable', github: 'morr/acts_as_voteable'

gem 'chronic', git: 'git@github.com:mojombo/chronic.git' # хак для совместимости whenever и ruby 2.0
gem 'whenever', require: false
gem 'clockwork', github: 'tomykaira/clockwork', require: false
gem 'foreman', github: 'morr/foreman' # для управления бекграунд процессами

gem 'thin'
gem 'faye'
gem 'faye-redis'
