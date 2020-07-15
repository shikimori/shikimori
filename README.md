[![CircleCI](https://circleci.com/gh/shikimori/shikimori.svg?style=svg&circle-token=5bd1a64ae9642ddb8d27a9585881756804ce9163)](https://circleci.com/gh/shikimori/shikimori)

## Contributing
Feel free to open tickets or send pull requests with improvements. Thanks in advance for your help!

Please follow the [contribution guidelines](https://github.com/shikimori/shikimori/blob/master/CONTRIBUTING.md).

## Requirements
OSX or Linux

PostgreSQL >= 10.0, Ruby >= 2.6, NodeJS >= 10.0, Elasticsearch >= 6.0, Memcached, Redis

## Issues Board (Agile Season)
https://agileseason.com/shared/boards/a98d1565b276f3781070f0e74a7ffcf1

## Requirements

### Checkout all projects
```sh
git clone git@github.com:shikimori/shikimori.git
git clone git@github.com:shikimori/neko-achievements.git
cd neko-achievements
mix deps.get
cd ..
git clone git@github.com:shikimori/camo-server.git
cd camo-server
yarn
cd ..
git clone git@github.com:shikimori/faye-server.git
cd faye-server
yarn
cd ..
cd shikimori
```

#### Install `yarn`, `tmux` and `overmind` via Homebrew (OSX)
```sh
brew install yarn tmux overmind
```
In linux you have to install them another way.

#### Install dependent gems and npm packages
```sh
yarn install
bundle install
```

## PostgreSQL
### DB
```sh
psql -d postgres
```
```sql
create user shikimori_production;
create user shikimori_test;
alter user shikimori_production createdb;
alter user shikimori_test createdb;
alter user shikimori_production with superuser;
alter user shikimori_test with superuser;
```

### Create databases
Make sure `en_US.UTF-8` database collation is set https://gist.github.com/ffmike/877447#gistcomment-2851598
```sh
rails db:create
```

### Extensions
```sh
psql -d shikimori_test_
```
```sql
CREATE EXTENSION unaccent;
CREATE EXTENSION hstore;
CREATE EXTENSION pg_stat_statements;
```

```sh
psql -d shikimori_production
```
```sql
CREATE EXTENSION unaccent;
CREATE EXTENSION hstore;
CREATE EXTENSION pg_stat_statements;
```

## Local Run
Everything you need to run is listed in [Procfile](https://github.com/shikimori/shikimori/blob/master/Procfile).
Shikimori uses [Overmind](https://github.com/DarthSim/overmind) to execute `Procfile`.


### Restore from a backup
```sh
rails db:drop && rails db:create
psql -U shikimori_production -d shikimori_production -f db/dump.sql
RAILS_ENV=test rails db:schema:load
rake db:migrate
```

### Start all services
```sh
overmind start
```

## Elasticsearch

In rails console:

```
AnimesIndex.reset!
MangasIndex.reset!
RanobeIndex.reset!
PeopleIndex.reset!
CharactersIndex.reset!
ClubsIndex.reset!
CollectionsIndex.reset!
ArticlesIndex.reset!
UsersIndex.reset!
TopicsIndex.reset!
```


## Update neko rules
```sh
rails neko:update
```

## Other
### Make a backup
```sh
pg_dump -c shikimori_production > db/dump.sql
```

### Autorun rspec & rubocop
```sh
guard
```

### Add new video hosting
```ruby
# app/services/video_extractor/player_url_extractor.rb
```

### Webpack debugger
https://nodejs.org/en/docs/inspector/
Install the Chrome Extension NIM (Node Inspector Manager): https://chrome.google.com/webstore/detail/nim-node-inspector-manage/gnhhdgbaldcilmgcpfddgdbkhjohddkj
```sh
~ RAILS_ENV=development NODE_ENV=development NODE_PATH=node_modules node --inspect node_modules/.bin/webpack-dev-server --progress --color --config config/webpack/development.js
```


### Webpack visualizer
https://chrisbateman.github.io/webpack-visualizer/

### Dependabot
```
@dependabot ignore this dependency
```

### Move data from development to production
```ruby
user = User.find(547860);

File.open('/tmp/z.json', 'w') do |f|
  f.write({
    user: user,
    user_preferences: user.preferences,
    style: user.style,
    user_history: UserHistory.where(user_id: user.id),
    user_rate_logs: UserRateLog.where(user_id: user.id),
    user_rates: UserRate.where(user_id: user.id)
  }.to_json);
end;
```

```sh
scp /tmp/z.json devops@shiki_web:/tmp/
```

```ruby
user_id = 547860;
json = JSON.parse(open('/tmp/z.json').read).symbolize_keys;

ApplicationRecord.transaction do
  UserRate.where(user_id: user_id).destroy_all;
  UserRate.wo_timestamp { UserRate.import(json[:user_rates].map {|v| UserRate.new v }); };
end

ApplicationRecord.transaction do
  UserRateLog.where(user_id: user_id).destroy_all;
  UserRateLog.wo_timestamp { UserRate.import(json[:user_rate_logs].map {|v| UserRateLog.new v }); };
end

ApplicationRecord.transaction do
  UserHistory.where(user_id: user_id).destroy_all;
  UserHistory.wo_timestamp { UserHistory.import(json[:user_history].map {|v| UserHistory.new v }); };
end

User.wo_timestamp { v = User.new json[:user]; v.save validate: false }
UserPreferences.wo_timestamp { v = UserPreferences.new json[:user_preferences]; v.save validate: false }
Style.wo_timestamp { v = Style.new json[:style]; v.save validate: false }

User.find(user_id).touch
```

### Generate favicons

```sh
convert -resize 144x144 /tmp/favicon.png public/favicons/ms-icon-144x144.png
convert -resize 228x228 /tmp/favicon.png public/favicons/opera-icon-228x228.png
convert -resize 180x180 /tmp/favicon.png public/favicons/apple-touch-icon-180x180.png
convert -resize 152x152 /tmp/favicon.png public/favicons/apple-touch-icon-152x152.png
convert -resize 144x144 /tmp/favicon.png public/favicons/apple-touch-icon-144x144.png
convert -resize 120x120 /tmp/favicon.png public/favicons/apple-touch-icon-120x120.png
convert -resize 114x114 /tmp/favicon.png public/favicons/apple-touch-icon-114x114.png

convert -resize 76x76 /tmp/favicon.png public/favicons/apple-touch-icon-76x76.png
convert -resize 72x72 /tmp/favicon.png public/favicons/apple-touch-icon-72x72.png
convert -resize 60x60 /tmp/favicon.png public/favicons/apple-touch-icon-60x60.png
convert -resize 57x57 /tmp/favicon.png public/favicons/apple-touch-icon-57x57.png

convert -resize 192x192 /tmp/favicon.png public/favicons/favicon-192x192.png
convert -resize 96x96 /tmp/favicon.png public/favicons/favicon-96x96.png
convert -resize 32x32 /tmp/favicon.png public/favicons/favicon-32x32.png
convert -resize 16x16 /tmp/favicon.png public/favicons/favicon-16x16.png

convert -resize 64x64 /tmp/favicon.png public/favicon.ico

# convert /tmp/favicon.png -bordercolor white -border 0 \
#   \( -clone 0 -resize 16x16 \) \
#   \( -clone 0 -resize 32x32 \) \
#   \( -clone 0 -resize 48x48 \) \
#   \( -clone 0 -resize 64x64 \) \
#   public/favicon.ico

cp app/assets/images/src/favicon.svg public/favicons/safari-pinned-tab.svg
```

### Grant access to pg_stat_statements_reset()
```sh
psql -d postgres
```
```sql
\connect shikimori_production;
GRANT EXECUTE ON FUNCTION pg_stat_statements_reset() TO shikimori_production;
```

### Generate apipie documentation
```sh
APIPIE_RECORD=all rspec spec/controllers/api/*
```

### Fix ElasticSearch readonly mode
https://www.elastic.co/guide/en/elasticsearch/reference/6.8/disk-allocator.html
```sh
curl -XPUT -H "Content-Type: application/json" http://192.168.0.2:9200/_cluster/settings \
  -d '{ "transient": {
    "cluster.routing.allocation.disk.watermark.low": "20gb",
    "cluster.routing.allocation.disk.watermark.high": "15gb",
    "cluster.routing.allocation.disk.watermark.flood_stage": "10gb"
  } }'
```
