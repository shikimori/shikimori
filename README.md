[![CircleCI](https://circleci.com/gh/shikimori/shikimori.svg?style=svg&circle-token=5bd1a64ae9642ddb8d27a9585881756804ce9163)](https://circleci.com/gh/shikimori/shikimori)

## Contributing
Feel free to open tickets or send pull requests with improvements. Thanks in advance for your help!

Please follow the [contribution guidelines](https://github.com/shikimori/shikimori/blob/master/CONTRIBUTING.md).

## PostgreSQL
### DB
```shell
~ psql -d postgres
postgres=# create user shikimori_production;
postgres=# create user shikimori_test;
postgres=# alter user shikimori_production createdb;
postgres=# alter user shikimori_test createdb;
postgres=# alter user shikimori_production with superuser;
postgres=# alter user shikimori_test with superuser;
```

### Extensions
```shell
~ psql -d shikimori_test
shikimori_test=# CREATE EXTENSION unaccent;
shikimori_test=# CREATE EXTENSION hstore;
shikimori_test=# CREATE EXTENSION pg_stat_statements;
```

```shell
~ psql -d shikimori_production
shikimori_production=# CREATE EXTENSION unaccent;
shikimori_production=# CREATE EXTENSION hstore;
shikimori_production=# CREATE EXTENSION pg_stat_statements;
```

### Restore from a backup
```shell
~ psql -U shikimori_production -d shikimori_production -f db/dump.sql
```

### Make a backup
```shell
~ pg_dump -c shikimori_production > db/dump.sql
```

## Start Service
```shell
~ brew install yarn
~ yarn install
~ cd ..
~ git clone git@github.com:shikimori/neko-achievements.git
~ git clone git@github.com:morr/camo.git
~ cd shikimori
~ brew install honcho # https://github.com/nickstenning/honcho
~ honcho start
```

## Elasticsearch
```rails console
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
~ rails neko:update
```


## Webpack debugger
https://nodejs.org/en/docs/inspector/
Install the Chrome Extension NIM (Node Inspector Manager): https://chrome.google.com/webstore/detail/nim-node-inspector-manage/gnhhdgbaldcilmgcpfddgdbkhjohddkj
```shell
~ RAILS_ENV=development NODE_ENV=development NODE_PATH=node_modules node --inspect node_modules/.bin/webpack-dev-server --progress --color --config config/webpack/development.js
```


## Webpack visualizer
https://chrisbateman.github.io/webpack-visualizer/
