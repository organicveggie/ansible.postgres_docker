#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "molecule" <<-EOSQL
	CREATE TABLE test (
        id int CONSTRAINT id_pk PRIMARY KEY
    );
    INSERT INTO test VALUES (42), (54);
EOSQL