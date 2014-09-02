source 'https://rubygems.org'

gem 'rake'
gem 'rails'

gem 'pg'
# NOTE: в конфиге мемкеша должна быть опция -I 16M
gem 'dalli'
gem 'redis'

gem 'libv8', '3.16.14.7' # нужно после перехода на yosemite
#gem 'sprockets-rails'
#gem "sprockets", "~> 2.11.0"
#gem "compass", "~> 1.0.0.alpha.19"

gem 'slim-rails'
gem 'coffee-rails'

gem 'sass-rails'
gem 'compass-rails'
gem 'turbolinks', github: 'morr/turbolinks', branch: 'master'
#gem 'susy'

gem 'uglifier'
gem 'non-stupid-digest-assets'

gem 'rmagick', require: 'RMagick', github: 'gemhome/rmagick', branch: 'master' # dependence: sudo apt-get install libmagickwand-dev
gem 'unicorn'

gem 'actionpack-action_caching'
gem 'attribute-defaults'
#gem 'attr_extras'
gem 'state_machine'
gem 'will_paginate', github: 'nazgum/will_paginate', branch: 'master'
gem 'nokogiri'
gem 'paperclip'
gem 'russian', github: 'yaroslav/russian'
gem 'metrika'
gem 'simple_form'
gem 'active_model_serializers'
gem 'virtus'

gem 'mobylette'
gem 'devise'
gem 'devise-async' # асинхронная отсылка писем для devise

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-vkontakte'
gem 'omniauth-twitter'

gem 'pghero'
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'sidekiq-limit_fetch'
gem 'sinatra', '>= 1.3.0', require: nil

#gem 'formtastic'
gem 'bb-ruby'
gem 'htmlentities' # для конвертации &#29190; -> 爆 у ворлдарта, мала и прочих
gem 'newrelic_rpm'
gem 'exception_notification'
gem 'awesome_print'
gem 'ruby-progressbar', github: 'morr/ruby-progressbar'
gem 'htmldiff', github: 'myobie/htmldiff'

gem 'retryable'
gem 'truncate_html'
gem 'acts-as-taggable-on'
gem 'uuid'
gem 'meta-tags', github: 'morr/meta-tags', require: 'meta_tags'
gem 'enumerize'
gem 'draper'
gem 'cancancan'

gem 'unicode' # для downcase русских слов
gem 'quote_extractor', github: 'morr/quote_extractor', tag: 'v0.0.2'
gem 'icalendar' # для аниме календраря
gem 'activerecord-import' # для быстрого импорта тегов
gem 'amatch', github: 'flori/amatch' # для поиска русских имён из википедии
gem 'ruby-svd', github: 'morr/Ruby-SVD' # для SVD рекомендаций. ruby 2.0
gem 'xxhash' # очень быстрый несекьюрный алгоритм хеширования (для comments_helper)

gem 'jbuilder' # для рендеринга json
gem 'rabl' # для рендеринга json
gem 'responders' # для json responder'а, который нужен для рендеринга контента на patch и put запросы
gem 'zaru'

gem 'postmark-rails'
gem 'apipie-rails'
gem 'gcm'

group :production do
  gem 'lograge'
end

group :development do
  gem 'spring'
  gem 'letter_opener'
  gem 'quiet_assets'
  #gem 'sextant'
  gem 'mactag'
  gem 'better_errors'
  #gem 'sprockets_better_errors'
  gem 'binding_of_caller'#, github: 'badosu/binding_of_caller'
  #gem 'sql-logging'

  gem 'capistrano'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  #gem 'capistrano-file-permissions', require: false, github: 'morr/file-permissions'
  gem 'rvm1-capistrano3', require: false

  gem 'foreman', github: 'morr/foreman' # для управления бекграунд процессами
end

gem 'marco-polo'
gem 'pry-rails'
gem 'pry-stack_explorer'

group :test, :development do
  gem 'byebug'
  #gem 'pry-byebug' # пока ещё не поддерживает byubug 3.0
  #
  gem 'rspec-rails'

  gem 'vcr'
  gem 'capybara'
  gem 'shoulda-matchers', require: false
  gem 'database_cleaner'

  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false

  gem 'spork', github: 'sporkrb/spork', branch: 'master'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-livereload'#, '2.1.2'

  gem 'timecop'
  gem 'webmock', '1.13'

  gem 'factory_girl_rails', require: false
end

gem 'acts_as_voteable', github: 'morr/acts_as_voteable', branch: 'master'

gem 'whenever', require: false
gem 'clockwork', require: false, github: 'zph/clockwork', branch: 'master' # TODO: заменить на оригинальный гем, когда пулреквест будет принят https://github.com/tomykaira/clockwork/pull/102

gem 'faye'
gem 'faye-redis'
gem 'thin'
