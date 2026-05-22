FROM debian:bookworm

RUN apt update &&\
    apt upgrade -y &&\
    apt-get install mariadb-server -y

COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init-db.sh /init-db.sh

RUN chmod +x /init-db.sh

ENTRYPOINT ["./init-db.sh"]