FROM postgres:9.4

COPY init-dh.sh /docker-entrypoint-initdb.d/init-patchwork.sh
