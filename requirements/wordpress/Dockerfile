FROM debian:bookworm

RUN apt update &&\
    apt upgrade -y &&\
    apt-get -y install wget &&\
    apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    mariadb-client &&\
    wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www


RUN cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz

RUN chown -R root:root /var/www/wordpress &&\
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&\
    chmod +x wp-cli.phar &&\
    mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY conf/auto-config.sh /

RUN chmod +x auto-config.sh

ENTRYPOINT ["./auto-config.sh"]