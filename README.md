[![CircleCI](https://circleci.com/gh/shikimori/shikimori.svg?style=svg&circle-token=5bd1a64ae9642ddb8d27a9585881756804ce9163)](https://circleci.com/gh/shikimori/shikimori)

## Contributing
Feel free to open tickets or send pull requests with improvements. Thanks in advance for your help!

Please follow the [contribution guidelines](https://github.com/shikimori/shikimori/blob/master/CONTRIBUTING.md).

## Requirements
OSX or Linux

PostgreSQL >= 10.0, Ruby >= 2.6, NodeJS >= 10.0, Elasticsearch 6.x (7.0 not supported), Memcached, Redis

## Issues Board (Agile Season)
https://agileseason.com/shared/boards/a98d1565b276f3781070f0e74a7ffcf1

## Requirements

### Checkout all projects
```sh
git clone git@github.com:shikimori/shikimori.git
git clone git@github.com:shikimori/neko-achievements.git
cd neko-achievements
mix local.hex --force
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

### Install `yarn`, `tmux` and `overmind` via Homebrew (OSX)
```sh
brew install yarn tmux overmind
```
In linux you have to install them another way.

### Install dependent gems and npm packages
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

Or you manually initialize new database with command
```sh
initdb --pgdata=/usr/local/var/postgres-13 -E 'UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8'
```

Create rails databases
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
unzip -d db/ db/dump.sql.zip
psql -U shikimori_production -d shikimori_production -f db/dump.sql
rm db/dump.sql
RAILS_ENV=test rails db:schema:load
# run three times because there will be error you can avoid with new run
rails db:migrate
rails db:migrate
rails db:migrate
```

### Start rails server
```sh
rails server
```
### Start related services
```sh
overmind start
```
### Start some of related services
```sh
OVERMIND_PROCESSES=camo,faye overmind start
```

## Elasticsearch

In rails console:

```
ClubsIndex.reset!
CollectionsIndex.reset!
ArticlesIndex.reset!
LicensorsIndex.reset!
FansubbersIndex.reset!
AnimesIndex.reset!
MangasIndex.reset!
RanobeIndex.reset!
PeopleIndex.reset!
CharactersIndex.reset!
TopicsIndex.reset!
UsersIndex.reset!
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
RAILS_ENV=development NODE_ENV=development NODE_PATH=node_modules node --inspect-brk node_modules/.bin/webpack-dev-server --progress --color --config config/webpack/development.js
```


### Webpack visualizer
https://chrisbateman.github.io/webpack-visualizer/

### Dependabot
```
@dependabot ignore this dependency
```

### Move anime data from development to production
```ruby
[14813, 33161, 18753, 23847].each do |anime_id|
  anime = Anime.find(anime_id);

  File.open("/tmp/anime_#{anime_id}.json", 'w') do |f|
    f.write({
      anime_id: anime_id,
      anime: anime,
      person_roles: anime.person_roles,
      user_rates: anime.rates,
      user_history: anime.user_histories,
      user_rate_logs: anime.user_rate_logs,
      topics: anime.all_topics,
      collection_links: anime.collection_links,
      versions: anime.versions,
      club_links: anime.club_links,
      contest_links: anime.contest_links,
      contest_winners: anime.contest_winners,
      favourites: anime.favourites,
      comments: (anime.all_topics + anime.reviews.flat_map(&:all_topics)).flat_map(&:comments),
      related: anime.related,
      similar: anime.similar,
      cosplay_gallery_links: anime.cosplay_gallery_links,
      reviews: anime.reviews,
      screenshots: anime.all_screenshots,
      videos: anime.videos,
      recommendation_ignores: anime.recommendation_ignores,
      anime_calendars: anime.anime_calendars,
      anime_videos: anime.anime_videos,
      episode_notifications: anime.episode_notifications,
      name_matches: anime.name_matches,
      links: anime.links,
      external_links: anime.external_links
    }.to_json);
  end;
end
```

```sh
scp /tmp/anime_*.json devops@shiki:/tmp/
```

```ruby
json = JSON.parse(open('/tmp/anime_33161.json').read).symbolize_keys;
anime_id = json['anime_id']

anime = Anime.wo_timestamp { z = Anime.find_or_initialize_by(id: json[:anime]['id']); z.assign_attributes json[:anime]; z.save validate: false; z };
anime.all_topics.destroy_all;

mappings = {
  related: RelatedAnime,
  similar: SimilarAnime,
  links: AnimeLink
}
%i[
  person_roles
  topics
  collection_links
  versions
  club_links
  contest_links
  contest_winners
  favourites
  related
  similar
  cosplay_gallery_links
  reviews
  screenshots
  videos
  recommendation_ignores
  anime_calendars
  anime_videos
  episode_notifications
  name_matches
  links
  external_links
  comments
].each do |kind|
  puts kind
  puts '=============================================='
  ApplicationRecord.transaction do
    klass = mappings[kind] || kind.to_s.classify.constantize
    klass.wo_timestamp { klass.import(json[kind].map {|v| klass.new v }, validate: false, on_duplicate_key_ignore: true); };
  end
end;

class UserRate < ApplicationRecord
  def log_created; end
  def log_deleted; end
end
ApplicationRecord.transaction do
  UserRate.where(target: anime).delete_all;
  UserRate.wo_timestamp { UserRate.import(json[:user_rates].map {|v| UserRate.new v }, validate: false, on_duplicate_key_ignore: true); };
end;

anime.touch;

# ApplicationRecord.transaction do
#   UserRateLog.where(target: anime).delete_all;
#   UserRateLog.wo_timestamp { UserRateLog.import(json[:user_rate_logs].map {|v| UserRateLog.new v }, validate: false); };
# end;

ApplicationRecord.transaction do
  UserHistory.where(target: anime).delete_all;
  UserHistory.wo_timestamp { UserHistory.import(json[:user_history].map {|v| UserHistory.new v }, validate: false, on_duplicate_key_ignore: true); };
end;

anime.touch;
User.where(id: UserRate.where(target: anime).select('user_id')).update_all updated_at: Time.zone.now;

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

### Manually refresh i18n-js translations
```sh
rails i18n:js:export
```

### Manually update proxies
```sh
rails runner "ProxyWorker.new.perform; File.open('/tmp/proxies.json', 'w') { |f| f.write Proxy.all.to_json }" && scp /tmp/proxies.json shiki:/tmp/ && ssh devops@shiki 'source /home/devops/.zshrc && cd /home/apps/shikimori/production/current && RAILS_ENV=production bundle exec rails runner "Proxy.transaction do; Proxy.delete_all; JSON.parse(open(\"/tmp/proxies.json\").read, symbolize_names: true).each {|v| Proxy.create! v }; end; puts Proxy.count"'
```

### Snippets

#### Convert topic to article
```ruby
ApplicationRecord.transaction do
  topic_id = 296373
  topic = Topic.find topic_id
  article = Article.create!(
    state: 'published',
    moderation_state: 'accepted',
    approver_id: 1,
    locale: 'ru',
    created_at: topic.created_at,
    updated_at: topic.updated_at,
    changed_at: topic.updated_at,
    name: topic.title,
    user_id: topic.user_id,
    body: topic.body
  )
  topic.update_columns(
    title: nil,
    forum_id: 21,
    type: "Topics::EntryTopics::ArticleTopic",
    generated: true,
    body: nil,
    linked_id: article.id,
    linked_type: 'Article'
  )
end
```

#### Restore from UserRateLog
```ruby
user_id = 794365;
scope = User.find(user_id).user_rate_logs.order(:id);

UserHistory.where(user_id: user_id).where('created_at >= ?', scope.first.created_at).each(&:destroy);

class UserRate < ApplicationRecord
  def log_created; end
  def log_deleted; end
end

UserRate.transaction do
  scope.each do |log|
    Timecop.freeze(log.created_at) do
      base_attrs = { user_id: user_id, target_type: log.target_type, target_id: log.target_id }
      diff_attrs = log.diff.except('id').each_with_object({}) {|(k,(old,new)),memo| memo[k] = new }

      if log.diff['id']
        if log.diff['id'][0].nil?
          base_attrs_with_id = base_attrs.merge('id' => log.diff['id'][1])

          prior_rate = UserRate.find_by(base_attrs)

          attrs = diff_attrs.merge(
            prior_rate ?
              prior_rate.attributes.except('id') :
              base_attrs_with_id
          )
          prior_rate&.destroy

          user_rate = UserRate.find_or_initialize_by(base_attrs_with_id)
          user_rate.assign_attributes(attrs)

          user_rate.save!
        else
          UserRate.find_by(id: log.diff['id'][0])&.destroy
        end
      else
        user_rate = UserRate.find_or_initialize_by(base_attrs)
        user_rate.assign_attributes(diff_attrs)
        ap user_rate
        user_rate.save!
      end
    end
  end
end

User.find(user_id).update! rate_at: Time.zone.now
```

#### Move user data from development to production
```ruby
user = User.find(794365);

class IPAddr
  def as_json(options = nil)
    to_s
  end
end

File.open('/tmp/z.json', 'w') do |f|
  f.write({
    # user: user,
    # user_preferences: user.preferences,
    # style: user.style,
    user_history: UserHistory.where(user_id: user.id),
    # user_rate_logs: UserRateLog.where(user_id: user.id),
    user_rates: UserRate.where(user_id: user.id)
  }.to_json);
end;
```

```sh
scp /tmp/z.json devops@shiki:/tmp/
ssh shiki
rc
```

```ruby
user_id = 794365;
json = JSON.parse(open('/tmp/x.json').read).symbolize_keys;

class UserRate < ApplicationRecord
  def log_created; end
  def log_deleted; end
end

ApplicationRecord.transaction do
  UserRate.where(user_id: user_id).destroy_all;
  UserRate.wo_timestamp { UserRate.import(json[:user_rates].map {|v| UserRate.new v }); };
end;

ApplicationRecord.transaction do
  UserRateLog.where(user_id: user_id).destroy_all;
  UserRateLog.wo_timestamp { UserRateLog.import(json[:user_rate_logs].map {|v| UserRateLog.new v }); };
 end;

ApplicationRecord.transaction do
  UserHistory.where(user_id: user_id).destroy_all;
  UserHistory.wo_timestamp { UserHistory.import(json[:user_history].map {|v| UserHistory.new v }); };
end;

# User.wo_timestamp { v = User.new json[:user]; v.save validate: false }
# UserPreferences.wo_timestamp { v = UserPreferences.new json[:user_preferences]; v.save validate: false }
# Style.wo_timestamp { v = Style.new json[:style]; v.save validate: false }

User.find(user_id).update rate_at: Time.zone.now
```
