source 'https://rubygems.org'

gem 'rake'
gem 'rails', '4.2.0'
gem 'railties', '4.2.0'
#gem 'bower-rails'

gem 'pg'
# NOTE: в конфиге мемкеша должна быть опция -I 16M
gem 'dalli'
gem 'redis'

gem 'slim-rails'
gem 'coffee-rails'

gem 'sass-rails', '5.0.0.beta1'
gem 'compass-rails'
gem 'turbolinks', github: 'morr/turbolinks', branch: 'master'

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
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-8-stable' # https://github.com/rails-api/active_model_serializers/issues/641
gem 'virtus'
gem 'attr_extras'

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
gem 'slack-notifier'
gem 'awesome_print'
gem 'ruby-progressbar', github: 'morr/ruby-progressbar'
gem 'htmldiff', github: 'myobie/htmldiff'

gem 'retryable'
gem 'truncate_html'
gem 'acts-as-taggable-on'
gem 'meta-tags', github: 'morr/meta-tags', require: 'meta_tags'
gem 'enumerize'
gem 'draper'
gem 'cancancan', github: 'morr/cancancan', branch: 'master'

gem 'unicode' # для downcase русских слов
gem 'quote_extractor', github: 'morr/quote_extractor', tag: 'v0.0.2'
gem 'icalendar' # для аниме календраря
gem 'activerecord-import' # для быстрого импорта тегов
gem 'amatch', github: 'flori/amatch' # для поиска русских имён из википедии
gem 'ruby-svd', github: 'morr/Ruby-SVD' # для SVD рекомендаций. ruby 2.0
gem 'xxhash' # очень быстрый несекьюрный алгоритм хеширования (для comments_helper)

gem 'jbuilder' # для рендеринга json
gem 'rack-contrib' # для поддержки jsonp в api
# TODO: выпилить отовсюду rabl, заменив его на jbuilder
gem 'rabl' # для рендеринга json
gem 'responders' # для json responder'а, который нужен для рендеринга контента на patch и put запросы
gem 'zaru'

gem 'postmark-rails'
gem 'apipie-rails'
gem 'gcm'

group :beta, :production do
  gem 'lograge'
end

group :development do
  gem 'spring'
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'mactag'
  #gem 'web-console'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'capistrano'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'slackistrano', require: false
  gem 'rvm1-capistrano3', require: false

  gem 'foreman', github: 'morr/foreman' # для управления бекграунд процессами
end

gem 'marco-polo'
gem 'pry-rails'
gem 'pry-stack_explorer'

group :test, :development do
  gem 'byebug'
  gem 'pry-byebug'

  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false

  gem 'listen', github: 'morr/listen'
  gem 'rspec'
  gem 'rspec-core'
  gem 'rspec-expectations'
  gem 'rspec-mocks'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'

  gem 'spring-commands-rspec'

  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-spring', require: false
  gem 'guard-pow', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails', require: false
  gem 'shoulda-matchers', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', require: false
end

gem 'acts_as_voteable', github: 'morr/acts_as_voteable', branch: 'master'

gem 'whenever', require: false
gem 'clockwork', require: false, github: 'zph/clockwork', branch: 'master' # TODO: заменить на оригинальный гем, когда пулреквест будет принят https://github.com/tomykaira/clockwork/pull/102

gem 'faye'
gem 'faye-redis'
gem 'thin'

# assets
source 'https://rails-assets.org' do
  gem 'rails-assets-jquery'
  gem 'rails-assets-eventie'
  gem 'rails-assets-eventEmitter'
  gem 'rails-assets-jquery-bridget'
  gem 'rails-assets-packery'
  # когда в master вольют https://github.com/dimsemenov/Magnific-Popup/pull/394 , то строку ниже заменить на её комментарий
  gem 'magnific-popup-rails', github: 'itsNikolay/magnific-popup-rails' # заменить на #gem 'rails-assets-magnific-popup'
end
