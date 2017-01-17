#!/bin/bash

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER patchwork UNENCRYPTED PASSWORD 'patchwork';
    CREATE DATABASE patchwork OWNER patchwork ENCODING 'utf-8';
EOSQL
