#!/bin/sh

until mysqladmin ping -h mariadb -u $SQL_USER -p$SQL_PASSWORD --silent 2>/dev/null; do
    sleep 1
done

# Ne créer wp-config.php que s'il n'existe pas déjà
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root \
        --path='/var/www/html'

    wp config create    --allow-root \
                        --dbname=$SQL_DATABASE \
                        --dbuser=$SQL_USER \
                        --dbpass=$SQL_PASSWORD \
                        --dbhost=mariadb:3306 \
                        --path='/var/www/html'

    wp core install --allow-root \
                    --url=$DOMAIN_NAME \
                    --title=$WP_TITLE \
                    --admin_user=$WP_ADMIN \
                    --admin_password=$WP_ADMIN_PASSWORD \
                    --admin_email=$WP_ADMIN_EMAIL \
                    --path='/var/www/html'

    wp user create $WP_ADMIN $WP_ADMIN_EMAIL  \
    --user_pass=$WP_ADMIN_PASSWORD \
    --role=administrator \
    --path='/var/www/html/' \
    --allow-root ;
fi

/usr/sbin/php-fpm8.2 -F