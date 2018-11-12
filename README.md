[![CircleCI](https://circleci.com/gh/shikimori/shikimori.svg?style=svg&circle-token=5bd1a64ae9642ddb8d27a9585881756804ce9163)](https://circleci.com/gh/shikimori/shikimori)

## Contributing
Feel free to open tickets or send pull requests with improvements. Thanks in advance for your help!

Please follow the [contribution guidelines](https://github.com/shikimori/shikimori/blob/master/CONTRIBUTING.md).

## Agile Season Board
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
psql -U shikimori_production -d shikimori_production -f db/dump.sql
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

#### Install `yarn` and `honcho`
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


## Webpack debugger
https://nodejs.org/en/docs/inspector/
Install the Chrome Extension NIM (Node Inspector Manager): https://chrome.google.com/webstore/detail/nim-node-inspector-manage/gnhhdgbaldcilmgcpfddgdbkhjohddkj
```sh
~ RAILS_ENV=development NODE_ENV=development NODE_PATH=node_modules node --inspect node_modules/.bin/webpack-dev-server --progress --color --config config/webpack/development.js
```


## Webpack visualizer
https://chrisbateman.github.io/webpack-visualizer/
