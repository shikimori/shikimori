# настройка постгреса
```
~ psql -d postgres
```
```
postgres=# create user shikimori_production with password 'bimpQscuJvkkL4Y';
postgres=# create user shikimori_test with password='bimpQscuJvkkL4Y';
postgres=# alter user shikimori_production createdb;
postgres=# alter user shikimori_test createdb;
```

# развёртка бекапа:
```
psql -U shikimori_production -d shikimori_production -f PostgreSQL.sql
```

# экстеншены для постгреса
```
~ psql -d shikimori_test
```
```
shikimori_test=# CREATE EXTENSION unaccent;
```
```
~ psql -d shikimori_production
```
```
shikimori_production=# CREATE EXTENSION unaccent;
```
