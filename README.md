[![Circle CI](https://circleci.com/gh/morr/shikimori.svg?style=svg)](https://circleci.com/gh/morr/shikimori)

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

# ban tor
```bash
sudo su
ipset -N tor2 iphash
wget -q "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=8.8.8.8" -O -|sed '/^#/d' |while read IP
do
  ipset -q -A tor2 $IP
done
# swap existing list to the new one
ipset swap tor tor2
ipset destroy tor2

sudo iptables -D INPUT -m set --match-set tor src -j DROP
sudo iptables -A INPUT -m set --match-set tor src -j DROP
```
