source 'https://rubygems.org'

gem 'rake'
gem 'rails', '4.0.4'

gem 'mysql2'
# NOTE: в конфиге мемкеша должна быть опция -I 16M
gem 'dalli'
gem 'redis'

gem 'therubyracer'
gem 'sprockets', '2.11.0'
gem 'sass-rails'
gem 'slim-rails'
gem 'susy', '1.0.8'
gem 'coffee-rails'
gem 'uglifier'
gem 'compass-rails'

gem 'rmagick', require: 'RMagick' # dependence: sudo apt-get install libmagickwand-dev
gem 'capistrano'
gem 'rvm-capistrano'

gem 'actionpack-action_caching'
gem 'attribute-defaults'
gem 'state_machine'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'nokogiri'
gem 'paperclip'
gem 'russian', github: 'yaroslav/russian'
gem 'metrika'
gem 'simple_form'
gem 'active_model_serializers'
gem 'virtus'

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

#gem 'formtastic'
gem 'bb-ruby'
gem 'htmlentities' # для конвертации &#29190; -> 爆 у ворлдарта, мала и прочих
gem 'newrelic_rpm'
gem 'exception_notification'
gem 'awesome_print'
gem 'ruby-progressbar', github: 'morr/ruby-progressbar'
gem 'htmldiff', github: 'myobie/htmldiff'

gem 'truncate_html'
gem 'acts-as-taggable-on'
gem 'uuid'
gem 'meta-tags', github: 'morr/meta-tags', require: 'meta_tags'
gem 'enumerize'
gem 'draper'

gem 'unicode' # для downcase русских слов
gem 'quote_extractor', github: 'morr/quote_extractor', tag: 'v0.0.2'
gem 'icalendar' # для аниме календраря
gem 'activerecord-import' # для быстрого импорта тегов
gem 'amatch', github: 'flori/amatch' # для поиска русских имён из википедии
gem 'ruby-svd', github: 'morr/Ruby-SVD' # для SVD рекомендаций. ruby 2.0
gem 'xxhash' # очень быстрый несекьюрный алгоритм хеширования (для comments_helper)

gem 'rabl' # для рендеринга json

gem 'postmark-rails'
gem 'apipie-rails'

group :production, :development do # чёртов гем ломает присвоение ассоциаций в FactoryGirl, и я не знаю, как это быстро починить другим способом
  gem 'composite_primary_keys' # для составного праймари кея у CommentView и EntryView
end

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  #gem 'sextant'
  gem 'mactag'
  gem 'better_errors'
  #gem 'sprockets_better_errors'
  gem 'binding_of_caller'#, github: 'badosu/binding_of_caller'
  gem 'sql-logging'
end

gem 'marco-polo'
gem 'pry-rails'
gem 'pry-stack_explorer'

group :development, :test do
  gem 'byebug'
  #gem 'pry-byebug' # пока ещё не поддерживает byubug 3.0
end

group :test, :development do
  gem 'rspec-rails'

  gem 'vcr'
  gem 'capybara'
  gem 'shoulda-matchers', require: false
  gem 'database_rewinder'

  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false

  gem 'spork', github: 'sporkrb/spork', branch: 'master'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-livereload', '2.1.2'

  gem 'timecop'
  gem 'webmock', '1.13'

  gem 'factory_girl_rails', require: false
end

gem 'acts_as_voteable', github: 'morr/acts_as_voteable', branch: 'master'

gem 'chronic', git: 'git@github.com:mojombo/chronic.git' # хак для совместимости whenever и ruby 2.0
gem 'whenever', require: false
gem 'clockwork', github: 'tomykaira/clockwork', require: false
gem 'foreman', github: 'morr/foreman' # для управления бекграунд процессами

gem 'thin'
gem 'faye', '0.8.1'
gem 'faye-redis', '0.1.0'
# все эти гемы для faye 0.8.1. когда обновлю faye до современной версии, надо удалить всё, что ниже
gem 'faye-websocket', '0.4.4'
#gem 'em-websocket', '0.3.8'
gem 'em-socksify', '0.2.0'
gem 'em-http-request'
gem 'em-hiredis', '0.1.1'
