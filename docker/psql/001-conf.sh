#!/usr/bin/env bash

# use same db as the one from env
dbname="$POSTGRES_DB"

echo "cron.database_name = '$dbname'" >> /var/lib/postgresql/data/postgresql.conf 
pg_ctl restart