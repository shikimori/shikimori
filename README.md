[![CircleCI](https://circleci.com/gh/shikimori/shikimori.svg?style=svg&circle-token=5bd1a64ae9642ddb8d27a9585881756804ce9163)](https://circleci.com/gh/shikimori/shikimori)

## Contributing
Feel free to open tickets or send pull requests with improvements. Thanks in advance for your help!

Please follow the [contribution guidelines](https://github.com/shikimori/shikimori/blob/master/CONTRIBUTING.md).

## Requirements
OSX or Linux
PostgreSQL >= 9.6, Ruby >= 2.6, NodeJS >= 10.0, Memcached, Redis

## Issues Board (Agile Season)
https://agileseason.com/shared/boards/a98d1565b276f3781070f0e74a7ffcf1

## PostgreSQL
### DB
```sh
psql -d postgres
postgres=# create user shikimori_production;
postgres=# create user shikimori_test;
postgres=# alter user shikimori_production createdb;
postgres=# alter user shikimori_test createdb;
postgres=# alter user shikimori_production with superuser;
postgres=# alter user shikimori_test with superuser;
```

### Create databases
```sh
rails db:create
```

### Extensions
```sh
psql -d shikimori_test
shikimori_test=# CREATE EXTENSION unaccent;
shikimori_test=# CREATE EXTENSION hstore;
shikimori_test=# CREATE EXTENSION pg_stat_statements;
```

```sh
psql -d shikimori_production
shikimori_production=# CREATE EXTENSION unaccent;
shikimori_production=# CREATE EXTENSION hstore;
shikimori_production=# CREATE EXTENSION pg_stat_statements;
```

### Restore from a backup
```sh
rails db:drop && rails db:create
psql -U shikimori_production -d shikimori_production -f db/dump.sql
RAILS_ENV=test rails db:schema:load
rake db:migrate
```

### Make a backup
```sh
pg_dump -c shikimori_production > db/dump.sql
```

## Local Run
### Requirements

#### Checkout all projects
```sh
git clone git@github.com:shikimori/shikimori.git
git clone git@github.com:shikimori/neko-achievements.git
git clone git@github.com:shikimori/camo-server.git
git clone git@github.com:shikimori/faye-server.git

cd shikimori
```

#### Install `yarn` and `honcho` (OSX)
```sh
brew install yarn
brew install honcho # https://github.com/nickstenning/honcho
```

#### Install dependent gems and npm packages
```sh
yarn install
bundle install
```

#### Start all services
```sh
honcho start
```

### Autorun rspec & rubocop
```sh
guard
```

## Elasticsearch

In rails console:

```
pry(main)> AnimesIndex.reset!
pry(main)> MangasIndex.reset!
pry(main)> RanobeIndex.reset!
pry(main)> PeopleIndex.reset!
pry(main)> CharactersIndex.reset!
pry(main)> ClubsIndex.reset!
pry(main)> CollectionsIndex.reset!
pry(main)> UsersIndex.reset!
pry(main)> TopicsIndex.reset!
```


## Update neko rules
```sh
rails neko:update
```


## Add new video hosting
```ruby
# app/services/video_extractor/player_url_extractor.rb
```


## Webpack debugger
https://nodejs.org/en/docs/inspector/
Install the Chrome Extension NIM (Node Inspector Manager): https://chrome.google.com/webstore/detail/nim-node-inspector-manage/gnhhdgbaldcilmgcpfddgdbkhjohddkj
```sh
~ RAILS_ENV=development NODE_ENV=development NODE_PATH=node_modules node --inspect node_modules/.bin/webpack-dev-server --progress --color --config config/webpack/development.js
```


## Webpack visualizer
https://chrisbateman.github.io/webpack-visualizer/

## Dependabot
```
@dependabot ignore this dependency
```

## Move data from development to production
```ruby
user = User.find(215190);

File.open('/tmp/z.json', 'w') do |f|
  f.write({
    user: user,
    user_preferences: user.preferences,
    style: user.style,
    user_history: UserHistory.where(user_id: user.id),
    user_rates: UserRate.where(user_id: user.id)
  }.to_json);
end;
```

```sh
scp /tmp/z.json devops@shiki_web:/tmp/
```

```
user_id = 215190;
json = JSON.parse(open('/tmp/z.json').read).symbolize_keys;

UserRate.where(user_id: user_id).destroy_all;
UserHistory.where(user_id: user_id).destroy_all;

UserHistory.wo_timestamp { UserHistory.import(json[:user_history].map {|v| UserHistory.new v }); };
UserRate.wo_timestamp { UserRate.import(json[:user_rates].map {|v| UserRate.new v }); };

User.wo_timestamp { v = User.new json[:user]; v.save validate: false }
UserPreferences.wo_timestamp { v = UserPreferences.new json[:user_preferences]; v.save validate: false }
Style.wo_timestamp { v = Style.new json[:style]; v.save validate: false }

User.find(user_id).touch
```

