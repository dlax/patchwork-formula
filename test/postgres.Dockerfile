FROM postgres:9.4

COPY init-db.sh /docker-entrypoint-initdb.d/init-patchwork.sh
